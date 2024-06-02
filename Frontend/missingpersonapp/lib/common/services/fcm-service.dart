import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:missingpersonapp/features/Notifications/screens/show_push_notification_click.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:missingpersonapp/main.dart'; // Import the main.dart to access the navigatorKey

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await _messaging.getToken();
      print("FCM Token: $token");
      if (token != null) {
        await sendTokenToBackend(token);
      }
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      _handleMessageClick(message);
    });

    // Check if the app was opened from a terminated state via a notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }
  }

  void _handleMessageClick(RemoteMessage message) {
    final data = message.data;
    print("clicked notification data ${data['caseID']}");
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ShowPushNotificationTap(
          theCase: data['caseID'],
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> sendTokenToBackend(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('authorization');
    final isLoggedIn = userToken != null && userToken.isNotEmpty;
    print('Is logged in: $isLoggedIn');

    if (isLoggedIn) {
      await updateUserFcmToken(token, userToken);
    } else {
      await storeGuestFcmToken(token);
    }
  }

  Future<void> storeGuestFcmToken(String token) async {
    print("Storing guest FCM token: $token");
    final response = await http.post(
      Uri.parse('${Constants.postUri}/api/store-guest-fcm-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'fcmToken': token,
      }),
    );

    if (response.statusCode == 201) {
      print('Guest FCM Token stored successfully.');
    } else {
      print(
          'Failed to store Guest FCM Token. Response code: ${response.statusCode}');
    }
  }

  Future<void> updateUserFcmToken(String token, String userToken) async {
    print("Updating user FCM token: $token");
    final response = await http.put(
      Uri.parse('${Constants.postUri}/api/update-user-fcm-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode(<String, String>{
        'fcmToken': token,
      }),
    );

    if (response.statusCode == 200) {
      print('User FCM Token updated successfully.');
    } else {
      print(
          'Failed to update User FCM Token. Response code: ${response.statusCode}');
    }
  }

  Future<void> deleteGuestFcmToken(String token) async {
    print("Deleting guest FCM token: $token");
    final response = await http.post(
      Uri.parse('${Constants.postUri}/delete-guest-fcm-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'fcmToken': token,
      }),
    );

    if (response.statusCode == 200) {
      print('Guest FCM Token deleted successfully.');
    } else {
      print(
          'Failed to delete Guest FCM Token. Response code: ${response.statusCode}');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  // Handle the message data here as needed
}
