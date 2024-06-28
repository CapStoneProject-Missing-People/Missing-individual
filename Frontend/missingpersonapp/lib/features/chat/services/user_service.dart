import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<User> fetchUserDetails(String userId, String token) async {
  final url = '${Constants.postUri}/api/users/getUserById/$userId';
  try {
    print('Requesting URL: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final userMap = jsonData['message'];
      return User.fromMap(userMap);
    } else {
      throw Exception('Failed to load user details');
    }
  } catch (e) {
    print('Error occurred: $e');
    rethrow;
  }
}
