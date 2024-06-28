import 'dart:typed_data';

class MissingPerson {
  final String poster_id;
  final String id;
  final String name;
  final String gender;
  final String middleName;
  final String lastName;
  final String posterName;
  final String posterEmail;
  final String posterPhone;
  final int age;
  final String skin_color;
  final String lastSeenLocation;
  final int timeSinceDisappearance;
  final String circumstanceOfDisappearance;
  final String upperClothType;
  final String upperClothColor;
  final String lowerClothType;
  final String lowerClothColor;
  final String status;
  final String medicalInformation;
  final String dateReported;
  final List<Uint8List> photos;
  final String description;
  final String bodySize;

  MissingPerson({
    required this.id,
    required this.poster_id,
    required this.posterName,
    required this.posterEmail,
    required this.name,
    required this.gender,
    required this.middleName,
    required this.lastName,
    required this.age,
    required this.skin_color,
    required this.photos,
    required this.posterPhone,
    required this.lastSeenLocation,
    required this.upperClothColor,
    required this.upperClothType,
    required this.lowerClothColor,
    required this.lowerClothType,
    required this.description,
    required this.status,
    required this.dateReported,
    required this.medicalInformation,
    required this.timeSinceDisappearance,
    required this.circumstanceOfDisappearance,
    required this.bodySize,
  });

  // Factory method to create a MissingPerson from JSON data
  factory MissingPerson.fromJson(Map<String, dynamic> data) {
    List<Uint8List> photos = [];
    if (data['photos'] != null) {
      photos = List<Uint8List>.from(
          data['photos'].map((photo) => Uint8List.fromList(photo.cast<int>())));
    }

    return MissingPerson(
      id: data['id'] ?? '',
      gender: data['gender'] ?? '',
      poster_id: data['poster_id'] ?? '',
      posterName: data['posterName'] ?? '',
      posterEmail: data['posterEmail'] ?? '',
      name: data['name'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      age: data['age'] ?? 0,
      skin_color: data['skin_color'] ?? '',
      photos: data['photos'] ?? [],
      posterPhone: data['posterPhone'] ?? '',
      lastSeenLocation: data['lastSeenLocation'] ?? '',
      medicalInformation: data['medicalInformation'] ?? '',
      upperClothColor: data['upperClothColor'] ?? '',
      upperClothType: data['upperClothType'] ?? '',
      lowerClothColor: data['lowerClothColor'] ?? '',
      lowerClothType: data['lowerClothType'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      timeSinceDisappearance: data['timeSinceDisappearance'] ?? '',
      circumstanceOfDisappearance: data['circumstanceOfDisappearance'] ?? '',
      dateReported: data['dateReported'] ?? '',
      bodySize: data['bodySize'] ?? '',
    );
  }
}
