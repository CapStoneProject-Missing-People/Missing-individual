import 'dart:convert';

import 'package:flutter/services.dart';

class MissingPersonAdd {
  final String firstName;
  final String lastName;
  final String middleName;
  final int age;
  final String? lastSeenPlace;
  final List<Uint8List> photos;
  final String phoneNumber;
  final String skinColor;
  final double firstNameMatch;
  final double middleNameMatch;
  final double lastNameMatch;
  final double ageMatch;
  final double skinColorMatch;
  final double upperclothColorMatch;
  final double upperclothTypeMatch;
  final double lowerclothColorMatch;
  final double lowerclothTypeMatch;
  final double eyeDescriptionMatch;
  final double noseDescriptionMatch;
  final double hairDescriptionMatch;
  final double lastSeenLocationMatch;
  final double lastAddressDescriptionMatch;
  final double lastTimeSeenMatch;
  final double? medicalInformationMatch;
  final double? circumstancesOfDisapperanceMatch;
  final double bodySizeMatch;

  MissingPersonAdd({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.age,
    this.lastSeenPlace,
    required this.photos,
    required this.phoneNumber,
    required this.skinColor,
    required this.firstNameMatch,
    required this.middleNameMatch,
    required this.lastNameMatch,
    required this.ageMatch,
    required this.skinColorMatch,
    required this.upperclothColorMatch,
    required this.upperclothTypeMatch,
    required this.lowerclothColorMatch,
    required this.lowerclothTypeMatch,
    required this.noseDescriptionMatch,
    required this.eyeDescriptionMatch,
    required this.hairDescriptionMatch,
    required this.lastSeenLocationMatch,
    required this.lastAddressDescriptionMatch,
    required this.lastTimeSeenMatch,
    this.medicalInformationMatch,
    this.circumstancesOfDisapperanceMatch,
    required this.bodySizeMatch,
  });

  factory MissingPersonAdd.fromJson(Map<String, dynamic> data) {
    // Decode each base64 image string to Uint8List
    final List<Uint8List> imageBuffers =
        (data['missing_case_id']['imageBuffers'] as List<dynamic>)
            .map((imageUrl) => base64Decode(imageUrl))
            .toList();

    return MissingPersonAdd(
      firstName: data['firstName'],
      lastName: data['lastName'],
      middleName: data['middleName'],
      age: data['age'],
      lastSeenPlace: data['lastSeenPlace'],
      photos: imageBuffers,
      phoneNumber: data['phoneNumber'] ?? '123-456-7890',
      skinColor: data['skin_color'],
      firstNameMatch: data['firstNameMatch'] ?? 0,
      middleNameMatch: data['middleNameMatch'] ?? 0,
      lastNameMatch: data['lastNameMatch'] ?? 0,
      ageMatch: data['ageMatch'] ?? 0,
      skinColorMatch: data['skinColorMatch'] ?? 0,
      upperclothColorMatch: data['upperclothColorMatch'] ?? 0,
      upperclothTypeMatch: data['upperclothTypeMatch'] ?? 0,
      lowerclothColorMatch: data['lowerclothColorMatch'] ?? 0,
      lowerclothTypeMatch: data['lowerclothTypeMatch'] ?? 0,
      noseDescriptionMatch: data['noseDescriptionMatch'] ?? 0,
      eyeDescriptionMatch: data['eyeDescriptionMatch'] ?? 0,
      hairDescriptionMatch: data['hairDescriptionMatch'] ?? 0,
      lastSeenLocationMatch: data['lastSeenLocationMatch'] ?? 0,
      lastAddressDescriptionMatch: data['lastAddressDescriptionMatch'] ?? 0,
      lastTimeSeenMatch: data['lastTimeSeenMatch'] ?? 0,
      medicalInformationMatch: data['lastTimeSeenMatch'] <= 0.5
          ? null
          : data['medicalInformationMatch'],
      circumstancesOfDisapperanceMatch: data['lastTimeSeenMatch'] <= 0.5
          ? null
          : data['circumstancesOfDisapperanceMatch'],
      bodySizeMatch: data['bodySizeMatch'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'age': age,
      'lastSeenPlace': lastSeenPlace,
      'photos': photos.map(base64Encode).toList(),
      'phoneNumber': phoneNumber,
      'skin_color': skinColor,
      'firstNameMatch': firstNameMatch,
      'middleNameMatch': middleNameMatch,
      'lastNameMatch': lastNameMatch,
      'ageMatch': ageMatch,
      'skinColorMatch': skinColorMatch,
      'upperclothColorMatch': upperclothColorMatch,
      'upperclothTypeMatch': upperclothTypeMatch,
      'lowerclothColorMatch': lowerclothColorMatch,
      'lowerclothTypeMatch': lowerclothTypeMatch,
      'eyeDescriptionMatch': eyeDescriptionMatch,
      'noseDescriptionMatch': noseDescriptionMatch,
      'hairDescriptionMatch': hairDescriptionMatch,
      'lastSeenLocationMatch': lastSeenLocationMatch,
      'lastAddressDescriptionMatch': lastAddressDescriptionMatch,
      'lastTimeSeenMatch': lastTimeSeenMatch,
      'bodySizeMatch': bodySizeMatch,
    };

    if (lastTimeSeenMatch > 0.5) {
      data['medicalInformationMatch'] = medicalInformationMatch;
      data['circumstancesOfDisapperanceMatch'] =
          circumstancesOfDisapperanceMatch;
    }

    return data;
  }
}
