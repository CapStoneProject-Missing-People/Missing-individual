import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:missingpersonapp/features/Notifications/models/notification_model.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class NotificationService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<NotificationModel>> fetchNotifications() async {
    print('fetching');
    final token = await _secureStorage.read(key: 'accessToken');
    print('token: $token');

    if (token == null) {
      throw Exception('User is not logged in');
    }

    final response = await http.get(
      Uri.parse('${Constants.postUri}/api/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}