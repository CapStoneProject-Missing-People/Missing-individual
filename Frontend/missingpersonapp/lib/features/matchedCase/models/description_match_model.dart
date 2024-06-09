class MissingPersonDescMatch {
  final String name;
  final int age;
  final String skin_color;
  final List<String> photos;
  final String phoneNumber;
  final String description;
  final double ageMatch;
  final double skinColorMatch;
  final double clothColorMatch;
  final double uniqueFeatureMatch;
  final double descriptionMatch;
  final double eyeColorMatch;
  final double bodySizeMatch;

  MissingPersonDescMatch({
    required this.name,
    required this.age,
    required this.skin_color,
    required this.photos,
    required this.phoneNumber,
    required this.description,
    required this.ageMatch,
    required this.skinColorMatch,
    required this.clothColorMatch,
    required this.uniqueFeatureMatch,
    required this.descriptionMatch,
    required this.eyeColorMatch,
    required this.bodySizeMatch,
  });

  factory MissingPersonDescMatch.fromJson(Map<String, dynamic> json) {
    return MissingPersonDescMatch(
      name: json['name'],
      age: json['age'],
      skin_color: json['skin_color'],
      photos: List<String>.from(json['photos']),
      phoneNumber: json['phone_number'],
      description: json['description'],
      ageMatch: json['age_match'].toDouble(),
      skinColorMatch: json['skin_color_match'].toDouble(),
      clothColorMatch: json['cloth_color_match'].toDouble(),
      uniqueFeatureMatch: json['unique_feature_match'].toDouble(),
      descriptionMatch: json['description_match'].toDouble(),
      eyeColorMatch: json['eye_color_match'].toDouble(),
      bodySizeMatch: json['body_size_match'].toDouble(),
    );
  }
}
