// fcm-service.dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:missingpersonapp/features/Notifications/provider/notification_provider.dart';
import 'package:missingpersonapp/features/Notifications/screens/show_push_notification_click.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/home/screens/match_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:missingpersonapp/main.dart'; // Import the main.dart to access the navigatorKey
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';

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

    _configureFirebaseListeners(context);
  }

  void _configureFirebaseListeners(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(context, message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageClick(context, message);
    });

    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessageClick(context, message);
      }
    });
  }

  void _handleMessage(BuildContext context, RemoteMessage message) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false); // Add this line

    if (userProvider.notificationsEnabled) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');
      final String jsondata = json.encode(message);
      print('message header: $jsondata');
      print('message header: ${message.notification?.title}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      // Fetch notifications to update the count
      await notificationProvider.fetchNotifications(); // Add this line
    }
  }

  void _handleMessageClick(BuildContext context, RemoteMessage message) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.notificationsEnabled) {
      final data = message.data;
      final notification = message.notification;
      print("notification ${notification?.title}");
      print("clicked notification data ${data['caseID']}");
      if (notification?.title == 'Face Recognition Match'){
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => PersonDetailsScreen(
                personId: data['caseID'],
              ),
            ),
          );
      }
      else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ShowPushNotificationTap(
              theCase: data['caseID'],
            ),
          ),
        );
      }
      
    }
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
