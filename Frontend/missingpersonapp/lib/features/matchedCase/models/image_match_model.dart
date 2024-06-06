import 'dart:typed_data';
import 'dart:convert';

class Match {
  final double distance;
  final double similarity;
  final DateTime createdAt;
  final String isMatch;
  final Uint8List imageBuffer;

  Match({
    required this.distance,
    required this.similarity,
    required this.createdAt,
    required this.isMatch,
    required this.imageBuffer,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      distance: double.parse(json['distance'].toString()),
      similarity: double.parse(json['similarity'].toString()),
      createdAt: DateTime.parse(json['createdAt']),
      isMatch: json['isMatch'],
      imageBuffer: base64Decode(json['imageBuffer'][0]),
    );
  }
}

class MatchedCase {
  final String id;
  final String userID;
  final String status;
  final List<Uint8List> imageBuffers;
  final bool faceFeatureCreated;
  final DateTime dateReported;
  final List<Match> matches;

  MatchedCase({
    required this.id,
    required this.userID,
    required this.status,
    required this.imageBuffers,
    required this.faceFeatureCreated,
    required this.dateReported,
    required this.matches,
  });

  factory MatchedCase.fromJson(Map<String, dynamic> json) {
    return MatchedCase(
      id: json['_id'],
      userID: json['userID'],
      status: json['status'],
      imageBuffers: (json['imageBuffers'] as List)
          .map((buffer) => buffer is String ? base64Decode(buffer) : Uint8List(0))
          .toList(),
      faceFeatureCreated: json['faceFeatureCreated'],
      dateReported: DateTime.parse(json['dateReported']),
      matches: (json['matches'] as List)
          .map((match) => Match.fromJson(match))
          .toList(),
    );
  }
}
