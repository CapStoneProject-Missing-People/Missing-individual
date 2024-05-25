import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/Notifications/models/notification_model.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final String baseUrl = ''; // Replace with your backend URL

  Future<List<NotificationModel>> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('fetching');
    String? token = prefs.getString('authorization');
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
