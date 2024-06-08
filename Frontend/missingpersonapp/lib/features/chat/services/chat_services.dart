import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/chat_session.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<List<ChatSession>> fetchChatSessionsFromApi(String userId) async {
  try {
    // http://localhost:4000/api/chat/getChatSessions/665f6ec4574eebd09ae9c7d8
    final response = await http.get(Uri.parse('${Constants.postUri}/api/chat/getChatSessions/$userId'));
    print('Response status: ${response.statusCode}');
    print('Response body: ');
    print(response.body);

    if (response.statusCode == 200) {
      print('before');
      final List<dynamic> jsonData = json.decode(response.body);
      print('after');
      return jsonData.map((json) => ChatSession.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat sessionss: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('inside chat services');
    print('Error occurred: $e');
    throw Exception('Failed to load chat sessions: $e');
  }
}
