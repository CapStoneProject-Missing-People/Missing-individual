import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/chat_session.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<List<ChatSession>> fetchChatSessionsFromApi(String userId) async {
  try {
    final response = await http.get(Uri.parse('${Constants.postUri}/api/chat/getChatSessions/$userId'));
    print('Response status: ${response.statusCode}');
    print('Response body: ');
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => ChatSession.fromJson(json as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 404) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['msg'] ?? 'Chat sessions not found');
    } else {
      throw Exception('Failed to load chat sessions');
    }
  } catch (e) {
    print('Error occurred: $e');
    rethrow;
  }
}
