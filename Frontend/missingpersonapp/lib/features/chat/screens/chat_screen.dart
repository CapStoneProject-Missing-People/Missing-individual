import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openMessagesBox() async {
    _messagesBox = await Hive.openBox<Message>('messages');
  }

  void _sendMessage(String content, [String? imageUrl]) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final senderId = user.id;
    final receiverId = widget.receiverId;

    final message = Message(
      id: DateTime.now().toString(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    _messagesBox.add(message);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.post(
      Uri.parse('${Constants.postUri}/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiver': receiverId,
        'message': content,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      print('Message sent successfully');
    } else {
      print('Failed to send message');
      return;
    }

    final socket = io.io('ws://${Constants.wsUri}');
    socket.emit('sendMessage', {
      'sender': senderId,
      'receiver': receiverId,
      'message': content,
      'imageUrl': imageUrl,
    });
    socket.close();

    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Convert image to byte buffer
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Send the image as a buffer
      _sendImageBuffer(base64Image);
    }
  }

  void _sendImageBuffer(String base64Image) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final senderId = user.id;
    final receiverId = widget.receiverId;

    // Create a message object
    final message = Message(
      id: DateTime.now().toString(),
      senderId: senderId,
      receiverId: receiverId,
      content: '',
      imageUrl: base64Image,
      timestamp: DateTime.now(),
    );

    // Add message to local storage
    _messagesBox.add(message);

    // Send message to backend
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.post(
      Uri.parse('${Constants.postUri}/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiver': receiverId,
        'message': '',
        'imageUrl': base64Image,
      }),
    );

    if (response.statusCode == 201) {
      print('Image sent successfully');
    } else {
      print('Failed to send image');
      return;
    }

    // Connect to socket.io server
    final socket = io.io('ws://${Constants.wsUri}');

    // Emit 'sendMessage' event to socket.io server
    socket.emit('sendMessage', {
      'sender': senderId,
      'receiver': receiverId,
      'message': '',
      'imageUrl': base64Image,
    });

    // Close socket connection
    socket.close();

    // Update UI
    setState(() {});
  }

  
  void _deleteMessage(Message message) async {
    // Remove from local storage
    print('message id');
    await _messagesBox.delete(message.id);

    // Remove from backend
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.delete(
      Uri.parse('${Constants.postUri}/api/chat/delete/${message.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // print(response);
    if (response.statusCode == 200) {
      print('Message deleted successfully');
    } else {
      print('Failed to delete message');
    }

    // Update UI
    setState(() {});
  }

  void _showDeleteConfirmationDialog(Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(message);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final currentUserId = user.id;
    final messages = _messagesBox.values.where((msg) =>
      (msg.senderId == currentUserId && msg.receiverId == widget.receiverId) ||
      (msg.senderId == widget.receiverId && msg.receiverId == currentUserId)).toList();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                bool isMe = message.senderId == currentUserId;
                return GestureDetector(
                  onLongPress: () {
                    _showDeleteConfirmationDialog(message);
                  },
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: isMe ? Radius.circular(10) : Radius.circular(0),
                            bottomRight: isMe ? Radius.circular(0) : Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (message.imageUrl != null)
                              Image.memory(
                                base64Decode(message.imageUrl!),
                                width: 200,
                                height: 200,
                              ),
                            if (message.content.isNotEmpty)
                              Text(
                                message.content,
                                style: TextStyle(fontSize: 16),
                              ),
                            SizedBox(height: 5),
                            Text(
                              message.timestamp.toString(),
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blue, size: 30),
                  onPressed: _pickImage,
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Enter message',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue, size: 30),
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
      backgroundColor: Colors.grey[100],
    );
  }
}
