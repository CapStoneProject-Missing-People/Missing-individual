import 'dart:convert';
import 'package:flutter/services.dart';

class MatchedPersonAddCompare {
  final String firstName;
  final String lastName;
  final String middleName;
  final int age;
  final String? lastSeenPlace;
  final List<Uint8List> photos;
  final String phoneNumber;
  final String skinColor;

  MatchedPersonAddCompare({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.age,
    this.lastSeenPlace,
    required this.photos,
    required this.phoneNumber,
    required this.skinColor,
  });

  factory MatchedPersonAddCompare.fromJson(Map<String, dynamic> data) {
    // Decode each base64 image string to Uint8List
    final List<Uint8List> imageBuffers =
        (data['missing_case_id']['imageBuffers'] as List<dynamic>)
            .map((imageUrl) => base64Decode(imageUrl))
            .toList();

    return MatchedPersonAddCompare(
      firstName: data['firstName'],
      lastName: data['lastName'],
      middleName: data['middleName'],
      age: data['age'],
      lastSeenPlace: data['lastSeenPlace'],
      photos: imageBuffers,
      phoneNumber: data['phoneNumber'] ?? '123-456-7890',
      skinColor: data['skin_color'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'age': age,
      'lastSeenPlace': lastSeenPlace,
      //'photos': photos.map(base64Encode).toList(),
      'phoneNumber': phoneNumber,
      'skin_color': skinColor,
    };

    return data;
  }
}
