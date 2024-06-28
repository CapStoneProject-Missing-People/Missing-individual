import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/chat/providers/message_provider.dart';
import 'package:provider/provider.dart';

Future<void> fetchMessagesFromAPI(BuildContext context, String receiverId) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final messageProvider = Provider.of<MessageProvider>(context, listen: false);
  final user = userProvider.user;

  final response = await http.get(
    Uri.parse('${Constants.postUri}/api/chat/$receiverId'),
    headers: {
      'Authorization': 'Bearer ${user.token}',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> messagesJson = json.decode(response.body);
    List<Message> messages = messagesJson.map((json) => Message.fromJson(json)).toList();
    messageProvider.setMessages(messages);
  } else {
    throw Exception('Failed to load messages');
  }
}
