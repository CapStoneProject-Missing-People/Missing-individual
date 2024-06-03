import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  Future<bool> updateUserProfile(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.put(
      Uri.parse('${Constants.postUri}/api/profile/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': user.name,
        'email': user.email,
        'phoneNo': user.phoneNo,
      }),
    );
    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response.statusCode == 200;
  }

  
Future<bool> deleteUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.delete(
      Uri.parse('${Constants.postUri}/api/profile/delete'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
