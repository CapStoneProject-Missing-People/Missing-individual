class FeedbackModel {
  final double rating;
  final String feedback;

  FeedbackModel({required this.rating, required this.feedback});

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'feedback': feedback,
    };
  }
}
