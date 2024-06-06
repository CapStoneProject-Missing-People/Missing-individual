import 'dart:typed_data';

class MissingPerson {
  final String user_id;
  final String name;
  final String userName;
  final String email;
  final int age;
  final String skin_color;
  final List<Uint8List> photos;
  final String phoneNo;
  final String description;

  MissingPerson({
    required this.user_id,
    required this.userName,
    required this.email,
    required this.name,
    required this.age,
    required this.skin_color,
    required this.photos,
    required this.phoneNo,
    required this.description,
  });

  // Factory method to create a MissingPerson from JSON data
  factory MissingPerson.fromJson(Map<String, dynamic> data) {
    List<Uint8List> photos = [];
    if (data['photos'] != null) {
      photos = List<Uint8List>.from(data['photos'].map((photo) => Uint8List.fromList(photo.cast<int>())));
    }

    return MissingPerson(
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      user_id: data['user_id'] ?? '',
      skin_color: data['skin_color'] ?? '',
      photos: photos,
      phoneNo: data['phoneNo'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
