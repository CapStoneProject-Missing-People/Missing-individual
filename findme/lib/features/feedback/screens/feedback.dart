// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
              label: _rating.toStringAsFixed(1),
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

  void _submitFeedback(BuildContext context) {
    String feedbackText = _feedbackController.text.trim();
    // Logging instead of printing
    _logger.i('Rating: $_rating');
    _logger.i('Feedback: $feedbackText');

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
  }
}

void main() {
  runApp(const MaterialApp(
    home: FeedbackPage(),
  ));
}
