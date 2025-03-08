import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/services/fcm-service.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/login_page.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'package:missingpersonapp/features/home/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FcmService _fcmService = FcmService();


  // Sign up user
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String phoneNo,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        phoneNo: phoneNo,
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.postUri}/api/users/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showToast(
            context,
            'Account created! Login with the same credentials!',
            Colors.green,
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showToast(context, 'A network error occurred', Colors.red);
      print(e.toString());
    }
  }

  // Sign in user
  Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${Constants.postUri}/api/users/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProvider.setUser(res.body);
          await prefs.setString('authorization', jsonDecode(res.body)['token']);

          String? fcmToken = await _fcmService.getToken();
          if (fcmToken != null) {
            await _fcmService.sendTokenToBackend(fcmToken);
          }

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showToast(context, 'A network error occurred', Colors.red);
      print(e.toString());
    }
  }

  // Get user data
  Future<void> getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authorization');

      if (token == null || token.isEmpty) {
        prefs.setString('authorization', '');
        return;
      }

      var tokenRes = await http.post(
        Uri.parse('${Constants.postUri}/api/users/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': "Bearer $token",
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('${Constants.postUri}/api/users/getUser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'authorization': "Bearer $token",
          },
        );

        httpErrorHandle(
          response: userRes,
          context: context,
          onSuccess: () async {
            userProvider.setUser(userRes.body);
            String? fcmToken = await _fcmService.getToken();
            if (fcmToken != null) {
              await _fcmService.sendTokenToBackend(fcmToken);
            }
          },
        );
      }
    } catch (err) {
      showToast(context, 'A network error occurred', Colors.red);
      print(err.toString());
    }
  }

  // Check if token is valid
  Future<bool> isTokenValid(String token) async {
    try {
      var tokenRes = await http.post(
        Uri.parse('${Constants.postUri}/api/users/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': "Bearer $token",
        },
      );
      var response = jsonDecode(tokenRes.body);
      return response == true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Sign out user
  Future<void> signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');

    // Notify the server about the logout
    await http.get(
      Uri.parse('${Constants.postUri}/api/users/tokenIsValid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': "Bearer $token",
      },
    );

    // Clear token and user data
    prefs.setString('authorization', '');
    Provider.of<UserProvider>(context, listen: false).clearUser();

    String? fcmToken = await _fcmService.getToken();
    if (fcmToken != null) {
      await _fcmService.sendTokenToBackend(fcmToken);
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
      (route) => false,
    );
  }
}