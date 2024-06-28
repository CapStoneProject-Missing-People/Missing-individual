import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:missingpersonapp/features/feedback/model/feedback_model.dart';

class FeedbackProvider with ChangeNotifier {
  Future<void> submitFeedback(BuildContext context, double rating, String feedbackText) async {
    if (feedbackText.isEmpty && rating == 0.0) {
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback.'),
          duration: Duration(seconds: 2),
        ),
      ); */
      showToast(
            context,
            'Please provide feedback.',
            Colors.red
          );
      return;
    }

    // Create the feedback data using the model
    final feedbackData = FeedbackModel(rating: rating, feedback: feedbackText.trim());

    // Send the feedback data to the backend
    final url = Uri.parse('${Constants.postUri}/api/postFeedBack');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'authorization': "Bearer $token",
      },
      body: jsonEncode(feedbackData.toJson()),
    );

    // Check the response status and show a message to the user
    if (response.statusCode == 201) {
      // Show a feedback message to the user
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          duration: Duration(seconds: 2),
        ),
      ); */
      showToast(
            context,
            'Thank you for your feedback!',
            Colors.green
          );
      notifyListeners();
    } else {
      // Handle error
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit feedback. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      ); */
      showToast(
            context,
            'Failed to submit feedback. Please try again later.',
            Colors.red
          );
    }
  }
}
