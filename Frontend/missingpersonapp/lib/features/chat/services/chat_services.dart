import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/chat_session.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<List<ChatSession>> fetchChatSessionsFromApi(String userId) async {
  final response = await http.get(Uri.parse('http://${Constants.postUri}/api/chats/$userId'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => ChatSession.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load chat sessions');
  }
}
