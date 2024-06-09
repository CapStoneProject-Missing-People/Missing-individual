import 'dart:typed_data';

class MissingPerson {
  final String missing_id;
  final String name;
  final String body_size;
  final int age;
  final String gender;
  final String skin_color;
  final String status;
  final List<Uint8List> photos;
  final String phoneNo;
  final String description;
  final String date_reported;

  MissingPerson({
    required this.missing_id,
    required this.name,
    required this.body_size,
    required this.age,
    required this.gender,
    required this.skin_color,
    required this.status,
    required this.photos,
    required this.phoneNo,
    required this.description,
    required this.date_reported,
  });

  // Factory method to create a MissingPerson from JSON data
  factory MissingPerson.fromJson(Map<String, dynamic> data) {
    List<Uint8List> photos = [];
    if (data['photos'] != null) {
      photos = List<Uint8List>.from(
          data['photos'].map((photo) => Uint8List.fromList(photo.cast<int>())));
    }

    return MissingPerson(
      name: data['name'] ?? '',
      body_size: data['body_size'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      skin_color: data['skin_color'] ?? '',
      photos: photos,
      phoneNo: data['phoneNo'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      date_reported: data['dateReported'] ?? '',
      missing_id: data['missing_id'] ?? '',
    );
  }
}
