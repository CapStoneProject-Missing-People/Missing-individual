import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> deleteMessageFromAPI(UserProvider userProvider, String messageId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authorization');

  final response = await http.delete(
    Uri.parse('${Constants.postUri}/api/chat/$messageId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete message');
  }
}


