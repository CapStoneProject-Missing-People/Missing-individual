import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class UserService {
  static const String _boxName = 'userCache';
  static const Duration _cacheDuration = Duration(hours: 1);
  static const Duration _timeout = Duration(seconds: 10);
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<User> fetchUserById(String userId) async {
    try {
      final cachedUser = await _getFromCache(userId);
      if (cachedUser != null) return cachedUser;

      final user = await _fetchFromNetwork(userId);
      await _saveToCache(userId, user);
      return user;
    } catch (e) {
      final cachedUser = await _getFromCache(userId, ignoreTimestamp: true);
      if (cachedUser != null) return cachedUser;
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  static Future<User?> _getFromCache(String userId, {bool ignoreTimestamp = false}) async {
    final box = await Hive.openBox<Map>(_boxName);
    final cached = box.get(userId);

    if (cached != null) {
      final timestamp = DateTime.parse(cached['timestamp']);
      if (ignoreTimestamp || DateTime.now().difference(timestamp) < _cacheDuration) {
        return User.fromJson(cached['data']);
      }
    }
    return null;
  }

  static Future<User> _fetchFromNetwork(String userId) async {
    final token = await _secureStorage.read(key: Constants.accessTokenKey);
    if (token == null) throw Exception('Authentication required');

    final response = await http.get(
      Uri.parse('${Constants.postUri}/api/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  static Future<void> _saveToCache(String userId, User user) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(userId, {
      'data': user.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> clearCache() async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.clear();
    await box.close();
  }
}
