import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/chat/providers/chat_provider.dart';
import 'package:missingpersonapp/features/chat/screens/chat_screen.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/chat/widgets/chatItem.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;

  ChatListScreen({required this.userId});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchChatSessions(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: chatProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : chatProvider.errorMessage.isNotEmpty
              ? Center(child: Text(chatProvider.errorMessage))
              : chatProvider.groupedChatSessions.isEmpty
                  ? Center(child: Text('No chats found'))
                  : ListView.builder(
                      itemCount: chatProvider.groupedChatSessions.length,
                      itemBuilder: (context, index) {
                        final otherUserId = chatProvider.groupedChatSessions.keys.elementAt(index);
                        final chat = chatProvider.groupedChatSessions[otherUserId]!;
                        final otherUserName = chat.userId1 == currentUser.id ? chat.userId2 : chat.userId1;
                        final lastMessageTime = chat.time;
                        final isChatWithSelf = otherUserId == currentUser.id;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChatItem(
                            username: otherUserName,
                            messagePreview: chat.message,
                            time: TimeOfDay.fromDateTime(lastMessageTime).format(context),
                            isRead: chat.read,
                            isChatWithSelf: isChatWithSelf,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(receiverId: otherUserId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
