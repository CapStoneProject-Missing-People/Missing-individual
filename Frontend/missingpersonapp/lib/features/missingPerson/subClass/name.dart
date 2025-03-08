import 'dart:convert';

class Name {
  String firstName;
  String middleName;
  String lastName;

  Name({
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
    };
  }

  factory Name.fromMap(Map<String, dynamic> map) {
    return Name(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Name.fromJson(String source) => Name.fromMap(json.decode(source));
}
