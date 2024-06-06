import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/chat/providers/chat_provider.dart';
import 'package:missingpersonapp/features/chat/screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String userId;

  ChatListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: FutureBuilder(
        future: chatProvider.fetchChatSessions(userId),
        builder: (context, snapshot) {
          if (chatProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (chatProvider.errorMessage.isNotEmpty) {
             print('chat provider');
             print(chatProvider.errorMessage);
            return Center(child: Text(chatProvider.errorMessage));
          } else if (chatProvider.chatSessions.isEmpty) {
            print('chat provider');
            print(chatProvider.chatSessions);
            return Center(child: Text('No chats found'));
          } else {
            return ListView.builder(
              itemCount: chatProvider.chatSessions.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.chatSessions[index];
                final otherUserId = chat.userId1 == userId ? chat.userId2 : chat.userId1;

                return ListTile(
                  title: Text('Chat with $otherUserId', overflow: TextOverflow.ellipsis),
                  subtitle: Text(chat.lastMessage, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(receiverId: otherUserId),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
