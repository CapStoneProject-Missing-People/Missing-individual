class FeatureCompare {
  final String id;
  final double firstNameMatch;
  final double middleNameMatch;
  final double lastNameMatch;
  final double genderMatch;
  final double skinColorMatch;
  final double lastSeenLocationMatch;
  final double medicalInformationMatch;
  final double circumstanceOfDisappearanceMatch;
  final double similarityScore;
  final double aggregateSimilarity;

  FeatureCompare({
    required this.id,
    required this.firstNameMatch,
    required this.middleNameMatch,
    required this.lastNameMatch,
    required this.genderMatch,
    required this.skinColorMatch,
    required this.lastSeenLocationMatch,
    required this.medicalInformationMatch,
    required this.circumstanceOfDisappearanceMatch,
    required this.similarityScore,
    required this.aggregateSimilarity,
  });

  factory FeatureCompare.fromJson(Map<String, dynamic> json) {
    return FeatureCompare(
      id: json['id'] ?? '',
      firstNameMatch: (json['name.firstName'] ?? 0).toDouble(),
      middleNameMatch: (json['name.middleName'] ?? 0).toDouble(),
      lastNameMatch: (json['name.lastName'] ?? 0).toDouble(),
      genderMatch: (json['gender'] ?? 0).toDouble(),
      skinColorMatch: (json['skin_color'] ?? 0).toDouble(),
      lastSeenLocationMatch: (json['lastSeenLocation'] ?? 0).toDouble(),
      medicalInformationMatch: (json['medicalInformation'] ?? 0).toDouble(),
      circumstanceOfDisappearanceMatch: (json['circumstanceOfDisappearance'] ?? 0).toDouble(),
      similarityScore: (json['similarityScore'] ?? 0).toDouble(),
      aggregateSimilarity: (json['aggregateSimilarity'] ?? 0).toDouble(),
    );
  }

  static List<FeatureCompare> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FeatureCompare.fromJson(json)).toList();
  }
}
