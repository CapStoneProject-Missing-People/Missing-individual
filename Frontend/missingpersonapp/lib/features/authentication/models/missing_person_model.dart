import 'dart:convert';
import 'dart:typed_data';

import 'package:missingpersonapp/features/authentication/models/subClass/clothing.dart';
import 'package:missingpersonapp/features/authentication/models/subClass/missingCase.dart';
import 'package:missingpersonapp/features/authentication/models/subClass/name.dart';



class MissingPersonSpecific {
  String id;
  String user_id;
  Name name;
  int age;
  String gender;
  String skin_color;
  String body_size;
  String lastSeenLocation;
  String featureType;
  String featureId;
  List<Uint8List> photos;
  String phoneNumber;
  String description;
  Clothing clothing;
  MissingCase missingCase;

  MissingPersonSpecific({
    required this.id,
    required this.user_id,
    required this.name,
    required this.age,
    required this.gender,
    required this.skin_color,
    required this.body_size,
    required this.lastSeenLocation,
    required this.featureType,
    required this.featureId,
    required this.photos,
    required this.phoneNumber,
    required this.description,
    required this.clothing,
    required this.missingCase,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name.toMap(),
      'age': age,
      'gender': gender,
      'skin_color': skin_color,
      'body_size': body_size,
      'lastSeenPlace': lastSeenLocation,
      'photos': photos.map((photo) => base64Encode(photo)).toList(),
      'phoneNumber': phoneNumber,
      'featureType': featureType,
      'featureId': featureId,
      'description': description,
      'clothing': clothing.toMap(),
      'missing_case_id': missingCase.toMap(),
    };
  }

  factory MissingPersonSpecific.fromMap(Map<String, dynamic> map) {
    return MissingPersonSpecific(
      id: map['_id'] ?? '',
      user_id: map['user_id'] ?? '',
      name: Name.fromMap(map['name'] ?? {}),
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      skin_color: map['skin_color'] ?? '',
      body_size: map['body_size'] ?? '',
      lastSeenLocation: map['lastSeenLocation'] ?? '',
      photos: (map['photos'] as List<dynamic>)
          .map((photo) => base64Decode(photo))
          .toList(),
      phoneNumber: map['phoneNumber'] ?? '',
      featureType: map['featureType'] ?? '',
      featureId: map['featureId'] ?? '',
      description: map['description'] ?? '',
      clothing: Clothing.fromMap(map['clothing'] ?? {}),
      missingCase: MissingCase.fromMap(map['missing_case_id'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory MissingPersonSpecific.fromJson(Map<String, dynamic> json) {
    return MissingPersonSpecific(
      id: json['_id'] ?? '',
      user_id: json['user_id'] ?? '',
      name: Name.fromMap(json['name'] ?? {}),
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      skin_color: json['skin_color'] ?? '',
      body_size: json['body_size'] ?? '',
      lastSeenLocation: json['lastSeenLocation'] ?? '',
      photos: (json['missing_case_id']['imageBuffers'] as List<dynamic>)
          .map((photo) => base64Decode(photo))
          .toList(),
      phoneNumber: json['phoneNumber'] ?? '',
      featureType: json['featureType'] ?? '',
      featureId: json['featureId'] ?? '',
      description: json['description'] ?? '',
      clothing: Clothing.fromMap(json['clothing'] ?? {}),
      missingCase: MissingCase.fromMap(json['missing_case_id'] ?? {}),
    );
  }
}




















/* class MissingPersonSpecific {
  String id;
  String user_id;
  Name name;
  int age;
  String gender;
  String skin_color;
  String body_size;
  String lastSeenLocation;
  List<String> photos;
  String phoneNumber;
  String description;
  Clothing clothing;
  MissingCase missingCase;

  MissingPersonSpecific({
    required this.id,
    required this.user_id,
    required this.name,
    required this.age,
    required this.gender,
    required this.skin_color,
    required this.body_size,
    required this.lastSeenLocation,
    required this.photos,
    required this.phoneNumber,
    required this.description,
    required this.clothing,
    required this.missingCase,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name.toMap(),
      'age': age,
      'gender': gender,
      'skin_color': skin_color,
      'body_size': body_size,
      'lastSeenPlace': lastSeenLocation,
      'photos': photos,
      'phoneNumber': phoneNumber,
      'description': description,
      'clothing': clothing.toMap(),
      'missing_case_id': missingCase.toMap(),
    };
  }

  factory MissingPersonSpecific.fromMap(Map<String, dynamic> map) {
    return MissingPersonSpecific(
      id: map['id'] ?? '',
      user_id: map['user_id'] ?? '',
      name: Name.fromMap(map['name'] ?? {}),
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      skin_color: map['skin_color'] ?? '',
      body_size: map['body_size'] ?? '',
      lastSeenLocation: map['lastSeenLocation'] ?? '',
      photos: List<String>.from(map['photos'] ?? const []),
      phoneNumber: map['phoneNumber'] ?? '',
      description: map['description'] ?? '',
      clothing: Clothing.fromMap(map['clothing'] ?? {}),
      missingCase: MissingCase.fromMap(map['missing_case_id'] ?? {}),
    );
  }
 */
  /* String toJson() => json.encode(toMap());


  factory MissingPersonSpecific.fromJson(Map<String, dynamic> json) {
    return MissingPersonSpecific(
      id: json['id'] ?? '',
      user_id: json['user_id'] ?? '',
      name: Name.fromMap(json['name'] ?? {}),
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      skin_color: json['skin_color'] ?? '',
      body_size: json['body_size'] ?? '',
      lastSeenLocation: json['lastSeenLocation'] ?? '',
      photos: List<String>.from(json['photos'] ?? const []),
      phoneNumber: json['phoneNumber'] ?? '',
      description: json['description'] ?? '',
      clothing: Clothing.fromMap(json['clothing'] ?? {}),
      missingCase: MissingCase.fromMap(json['missing_case_id'] ?? {}),
    );
  } */
