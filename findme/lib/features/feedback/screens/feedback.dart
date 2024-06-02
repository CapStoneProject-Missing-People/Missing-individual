import 'package:findme/features/feedback/model/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0.0;
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Rate your experience:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _submitFeedback(context),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback(BuildContext context) async {
    String feedbackText = _feedbackController.text.trim();

    if (feedbackText.isEmpty && _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback text or a rating.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create the feedback data using the model
    final feedbackData = FeedbackModel(rating: _rating, feedback: feedbackText);

    // Log the feedback data
    _logger.i('Rating: ${feedbackData.rating}');
    _logger.i('Feedback: ${feedbackData.feedback}');

    // Send the feedback data to the backend
    final url = Uri.parse('http://example.com/api/feedback');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(feedbackData.toJson()),
    );

    // Check the response status and show a message to the user
    if (response.statusCode == 200) {
      // Show a feedback message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the feedback text field and reset rating
      _feedbackController.clear();
      setState(() {
        _rating = 0.0;
      });
    } else {
      // Handle error
      _logger.e('Failed to submit feedback: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit feedback. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: FeedbackPage(),
  ));
}
