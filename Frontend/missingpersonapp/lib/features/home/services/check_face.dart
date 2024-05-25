import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class CheckFace extends StatefulWidget {
  final String imagePath;

  const CheckFace({super.key, required this.imagePath});

  @override
  _CheckFaceState createState() => _CheckFaceState();
}

class _CheckFaceState extends State<CheckFace> {
  String? _apiResult;
  bool _loading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 200, // Set the width as desired
            child: Image.file(File(widget.imagePath)),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _loading = true; // Show loading state when button is clicked
              });
              final String? result = await _sendImageToAPI(widget.imagePath);
              setState(() {
                _loading = false; // Hide loading state after API call completes
                _apiResult = result;
              });
            },
            child: const Text('Search Me'),
          ),
          if (_loading) // Conditional rendering for displaying loading indicator
            const CircularProgressIndicator(),
          if (_apiResult !=
              null) // Conditional rendering for displaying API result
            Text(_apiResult!),
        ],
      ),
    );
  }

  Future<String?> _sendImageToAPI(String imagePath) async {
    String apiUrl = '${Constants.faceApi}/recognize';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('File1', imagePath));

      var streamedResponse = await request.send();
      var response = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        return response;
      } else {
        print('Error uploading image: ${streamedResponse.statusCode}');
        print('Response: $response');
        return "Error uploading image: ${streamedResponse.statusCode}";
      }
    } catch (e) {
      print('Exception while uploading image: $e');
      return "Exception while uploading image: $e";
    }
  }
}
