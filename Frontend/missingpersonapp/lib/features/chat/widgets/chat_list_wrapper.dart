import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/chat/screens/chat_list_screen.dart';
import 'package:provider/provider.dart';

class ChatListWrapper extends StatelessWidget {
  const ChatListWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).user.id;
    return ChatListScreen(userId: userId);
  }
}
