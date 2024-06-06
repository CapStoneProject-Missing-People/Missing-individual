import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/home/provider/allMissingperson.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Box<Message> _messagesBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _openMessagesBox();
    await _fetchMissingPersons();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openMessagesBox() async {
    _messagesBox = await Hive.openBox<Message>('messages');
  }

  Future<void> _fetchMissingPersons() async {
    final allMissingPeopleProvider = Provider.of<AllMissingPeopleProvider>(context, listen: false);
    await allMissingPeopleProvider.fetchMissingPersons();
  }

  void _sendMessage(String content) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user; // This is user1
    final allMissingPeopleProvider = Provider.of<AllMissingPeopleProvider>(context, listen: false);

    final senderId = user.id; // user1's id
    final receiverId = widget.receiverId; // user2's id passed from the post

    // Create a message object
    final message = Message(
      id: DateTime.now().toString(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    // Add message to local storage
    _messagesBox.add(message);

    // Send message to backend
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.post(
      Uri.parse('http://${Constants.postUri}:4000/api/chat'), // Replace with your backend URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}', // Replace with your authentication token
      },
      body: jsonEncode({
        'receiver': receiverId,
        'message': content,
        // Add any other fields you need to send to the backend
      }),
    );

    // Check if the message was sent successfully to the backend
    if (response.statusCode == 201) {
      // Message sent successfully
      print('Message sent successfully');
    } else {
      // Failed to send message
      print('Failed to send message');
      return;
    }

    // Connect to socket.io server
    final socket = io.io('ws://${Constants.postUri}:4000');

    // Emit 'sendMessage' event to socket.io server
    socket.emit('sendMessage', {
      'sender': senderId,
      'receiver': receiverId,
      'message': content,
      // Add any other fields you need to send to the socket.io server
    });

    // Close socket connection
    socket.close();

    // Update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user; // This is user1
    final allMissingPeopleProvider = Provider.of<AllMissingPeopleProvider>(context);

    if (_isLoading || allMissingPeopleProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (allMissingPeopleProvider.errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(child: Text(allMissingPeopleProvider.errorMessage)),
      );
    }

    final currentUserId = user.id; // user1's id
    final messages = _messagesBox.values.where((msg) =>
      (msg.senderId == currentUserId && msg.receiverId == widget.receiverId) ||
      (msg.senderId == widget.receiverId && msg.receiverId == currentUserId)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text(message.timestamp.toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
