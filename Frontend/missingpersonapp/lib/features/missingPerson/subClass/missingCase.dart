import 'dart:convert';

class MissingCase {
  String id;
  String status;
  List<String> imagePaths;
  DateTime dateReported;

  MissingCase({
    required this.id,
    required this.status,
    required this.imagePaths,
    required this.dateReported,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'status': status,
      'imagePaths': imagePaths,
      'dateReported': dateReported.toIso8601String(),
    };
  }

  factory MissingCase.fromMap(Map<String, dynamic> map) {
    return MissingCase(
      id: map['_id'] ?? '',
      status: map['status'] ?? '',
      imagePaths: List<String>.from(map['imagePaths'] ?? const []),
      dateReported: DateTime.parse(
          map['dateReported'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MissingCase.fromJson(String source) =>
      MissingCase.fromMap(json.decode(source));
}
