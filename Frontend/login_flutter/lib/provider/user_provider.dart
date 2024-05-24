import 'package:flutter/material.dart';
import 'package:flutter3/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user =
      User(id: '', name: '', email: '', token: '', password: '', phoneNo: '');

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
