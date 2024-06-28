// models/matching_status.dart
import 'dart:convert';
import 'dart:typed_data';

class MatchingStatus {
  final int age;
  final int firstName;
  final int middleName;
  final int lastName;
  final int gender;
  final int skinColor;
  final int description;
  final int similarityScore;
  final int bodySize;
  final int lastSeenLocation;
  final int medicalInformation;
  final int circumstanceOfDisappearance;
  final double aggregateSimilarity;

  MatchingStatus({
    required this.age,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.skinColor,
    required this.description,
    required this.similarityScore,
    required this.bodySize,
    required this.lastSeenLocation,
    required this.medicalInformation,
    required this.circumstanceOfDisappearance,
    required this.aggregateSimilarity,
  });

  factory MatchingStatus.fromJson(Map<String, dynamic> json) {
    print('Parsing MatchingStatus: $json');
    return MatchingStatus(
      age: json['age'] ?? 0,
      firstName: json['firstName'] ?? 0,
      middleName: json['middleName'] ?? 0,
      lastName: json['lastName'] ?? 0,
      gender: json['gender'] ?? 0,
      skinColor: json['skinColor'] ?? 0,
      description: json['description'] ?? 0,
      similarityScore: json['similarityScore'] ?? 0,
      bodySize: json['bodySize'] ?? 0,
      lastSeenLocation: json['lastSeenLocation'] ?? 0,
      medicalInformation: json['medicalInformation'] ?? 0,
      circumstanceOfDisappearance: json['circumstanceOfDisappearance'] ?? 0,
      aggregateSimilarity: (json['aggregateSimilarity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CaseDetails {
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final int age;
  final String skinColor;
  final String bodySize;
  final String description;
  final int timeSinceDisappearance;
  final String inputHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String userId;
  final MissingCaseDetails missingCaseId;

  CaseDetails({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.skinColor,
    required this.bodySize,
    required this.description,
    required this.timeSinceDisappearance,
    required this.inputHash,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.userId,
    required this.missingCaseId,
  });

  factory CaseDetails.fromJson(Map<String, dynamic> json) {
    print('Parsing CaseDetails: $json');
    return CaseDetails(
      firstName: json['name']['firstName'] ?? '',
      middleName: json['name']['middleName'] ?? '',
      lastName: json['name']['lastName'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      skinColor: json['skin_color'] ?? '',
      bodySize: json['body_size'] ?? '',
      description: json['description'] ?? '',
      timeSinceDisappearance: json['timeSinceDisappearance'] ?? 0,
      inputHash: json['inputHash'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? '1970-01-01T00:00:00Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '1970-01-01T00:00:00Z'),
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      missingCaseId: MissingCaseDetails.fromJson(json['missing_case_id'] ?? {}),
    );
  }
}

// models/missing_case_details.dart

class MissingCaseDetails {
  final String id;
  final String userId;
  final String status;
  final List<Uint8List> imageBuffers;
  final bool faceFeatureCreated;
  final DateTime dateReported;

  MissingCaseDetails({
    required this.id,
    required this.userId,
    required this.status,
    required this.imageBuffers,
    required this.faceFeatureCreated,
    required this.dateReported,
  });

  factory MissingCaseDetails.fromJson(Map<String, dynamic> json) {
    print('Parsing MissingCaseDetails: $json');
    return MissingCaseDetails(
      id: json['_id'] ?? '',
      userId: json['userID'] ?? '',
      status: json['status'] ?? '',
      imageBuffers: json['imageBuffers'] != null
          ? List<Uint8List>.from(json['imageBuffers'].map((buffer) => base64Decode(buffer)))
          : [],
      faceFeatureCreated: json['faceFeatureCreated'] ?? false,
      dateReported: DateTime.parse(json['dateReported'] ?? '1970-01-01T00:00:00Z'),
    );
  }
}

class PotentialMatch {
  final MatchingStatus matchingStatus;
  final String id;
  final String userId;
  final CaseDetails? newCaseDetails;
  final CaseDetails? existingCaseDetails;

  PotentialMatch({
    required this.matchingStatus,
    required this.id,
    required this.userId,
    this.newCaseDetails,
    this.existingCaseDetails,
  });

  factory PotentialMatch.fromJson(Map<String, dynamic> json) {
    print('Parsing PotentialMatch: $json');
    return PotentialMatch(
      matchingStatus: MatchingStatus.fromJson(json['matchingStatus'] ?? {}),
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      newCaseDetails: json['newCaseDetails'] != null
          ? CaseDetails.fromJson(json['newCaseDetails'])
          : null,
      existingCaseDetails: json['existingCaseDetails'] != null
          ? CaseDetails.fromJson(json['existingCaseDetails'])
          : null,
    );
  }
}
