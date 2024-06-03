import 'dart:convert';

class UserData {
  final String id;
  final String name;
  final String email;
  final String token;
  final String password;
  final String phoneNo;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.password,
    required this.phoneNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'password': password,
      'phoneNo': phoneNo,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      password: map['password'] ?? '',
      phoneNo: map['phoneNo'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) => UserData.fromMap(json.decode(source));

  UserData copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? password,
    String? phoneNo,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      password: password ?? this.password,
      phoneNo: phoneNo ?? this.phoneNo,
    );
  }
}
