class MatchedPersonAdd {
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

  MatchedPersonAdd({
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

  factory MatchedPersonAdd.fromJson(Map<String, dynamic> json) {
    return MatchedPersonAdd(
      id: json['id'],
      firstNameMatch: json['firstNameMatch'].toDouble(),
      middleNameMatch: json['middleNameMatch'].toDouble(),
      lastNameMatch: json['lastNameMatch'].toDouble(),
      genderMatch: json['genderMatch'].toDouble(),
      skinColorMatch: json['skinColorMatch'].toDouble(),
      lastSeenLocationMatch: json['lastSeenLocationMatch'].toDouble(),
      medicalInformationMatch: json['medicalInformationMatch'].toDouble(),
      circumstanceOfDisappearanceMatch:
          json['circumstanceOfDisappearanceMatch'].toDouble(),
      similarityScore: json['similarityScore'].toDouble(),
      aggregateSimilarity: json['aggregateSimilarity'].toDouble(),
    );
  }
}
