import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/Profile/services/profile_manage.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User _user =
      User(id: '', name: '', email: '', token: '', password: '', phoneNo: '');
  bool _notificationsEnabled = true; // Default value

  User get user => _user;
  bool get notificationsEnabled => _notificationsEnabled;

  void setUser(String userJson) {
    _user = User.fromJson(userJson);
    notifyListeners();
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

  Future<bool> updateUserProfile(String userJson) async {
    User user = User.fromJson(userJson);
    bool success = await ProfileService().updateUserProfile(user);
    if (success) {
      setUser(userJson);
    } else {
      print("Failed to update user profile on server.");
    }
    return success;
  }

  Future<bool> deleteUserProfile() async {
    bool success = await ProfileService().deleteUserProfile();
    if (success) {
      // Reset the user to an empty state
      _user = User(
          id: '', name: '', email: '', token: '', password: '', phoneNo: '');
      notifyListeners();
    }
    return success;
  }
}
