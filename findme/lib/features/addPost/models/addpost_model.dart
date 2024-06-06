class MissingPerson {
  final String firstName;
  final String middleName;
  final String lastName;
  final String lastSeenLocation;
  final String lastAddressDesc;
  final int lastTimeSeen;
  final String gender;
  final int age;
  final String skinColor;
  final String upperClothType;
  final String upperClothColor;
  final String lowerClothType;
  final String lowerClothColor;
  final String bodySize;
  final String eyeDescription;
  final String noseDescription;
  final String hairDescription;
  final String medicalInformation;
  final String circumstanceOfDisappearance;
  final List<String> imagePaths;

  MissingPerson({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.lastSeenLocation,
    required this.lastAddressDesc,
    required this.lastTimeSeen,
    required this.gender,
    required this.age,
    required this.skinColor,
    required this.upperClothType,
    required this.upperClothColor,
    required this.lowerClothType,
    required this.lowerClothColor,
    required this.bodySize,
    required this.eyeDescription,
    required this.noseDescription,
    required this.hairDescription,
    required this.medicalInformation,
    required this.circumstanceOfDisappearance,
    required this.imagePaths,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'lastSeenLocation': lastSeenLocation,
      'lastSeenAddressDes': lastAddressDesc,
      'timesincedisapprearance': lastTimeSeen,
      'gender': gender,
      'age': age,
      'skinColor': skinColor,
      'upperClothType': upperClothType,
      'upperClothColor': upperClothColor,
      'lowerClothType': lowerClothType,
      'lowerClothColor': lowerClothColor,
      'bodySize': bodySize,
      'eyeDescription': eyeDescription,
      'noseDescription': noseDescription,
      'hairDescription': hairDescription,
      'medicalInformation': medicalInformation,
      'circumstanceOfDisappearance': circumstanceOfDisappearance,
      'imagePaths': imagePaths,
    };
  }
}
