class MatchedCase {
  final String id;
  final String userID;
  final String status;
  final List<dynamic> imageBuffers;
  final bool faceFeatureCreated;
  final DateTime dateReported;
  final List<dynamic> matches;

  MatchedCase({
    required this.id,
    required this.userID,
    required this.status,
    required this.imageBuffers,
    required this.faceFeatureCreated,
    required this.dateReported,
    required this.matches,
  });
}
