import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/Profile/services/profile_manage.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User _user =
      User(id: '', name: '', email: '', token: '', password: '', phoneNo: '');
  bool _notificationsEnabled = true; // Default value

  User get user => _user;
  bool get notificationsEnabled => _notificationsEnabled;

  // Updated to accept a Map<String, dynamic>
  void setUser(Map<String, dynamic> userMap) {
    _user = User.fromMap(userMap); // Use fromMap constructor
    notifyListeners();
  }

  // Helper method to handle JSON strings (for backward compatibility)
  void setUserFromJson(String userJson) {
    final userMap = jsonDecode(userJson); // Convert JSON string to Map
    setUser(userMap); // Call the updated setUser method
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  void toggleNotifications(bool isEnabled) async {
    _notificationsEnabled = isEnabled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  // Updated to work with Map<String, dynamic>
  Future<bool> updateUserProfile({
    required BuildContext context,
    required Map<String, dynamic> userMap,
  }) async {
    User user = User.fromMap(userMap); // Use fromMap constructor
    print('User to be updated: $user');
    bool success = await ProfileService().updateUserProfile(
      context: context,
      user: user,
    );
    if (success) {
      setUser(userMap); // Pass the Map to setUser
    } else {
      print("Failed to update user profile on server.");
    }
    return success;
  }

  Future<bool> deleteUserProfile({
    required BuildContext context,
  }) async {
    bool success = await ProfileService().deleteUserProfile(
      context: context,
    );
    if (success) {
      // Reset the user to an empty state
      _user = User(
          id: '', name: '', email: '', token: '', password: '', phoneNo: '');
      notifyListeners();
    }
    return success;
  }

  void clearUser() {
    _user = User(
      id: '',
      name: '',
      email: '',
      phoneNo: '',
      token: '',
      password: '',
    );
    notifyListeners();
  }
}
