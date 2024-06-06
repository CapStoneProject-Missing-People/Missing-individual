import 'dart:typed_data';
import 'package:findme/features/compare/model/matched-compare.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Constants {
  static String postUri = 'http://192.168.23.140:4000';
  static String faceApi = 'http://192.168.23.140:6000';
}

Future<List<MatchedPersonAddCompare>> fetchMatchedPeople(String userId) async {
  print("Fetching matched people for user ID: $userId...");

  final String url = "${Constants.postUri}/api/features/getSingle/$userId";
  print("Request URL: $url");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> jsonData = json.decode(response.body);
      // Map the parsed data to instances of MatchedPersonAddCompare class
      List<MatchedPersonAddCompare> matchedPeople = jsonData.map((data) {
        // Decode each base64 image string to Uint8List
        final List<Uint8List> imageBuffers =
            (data['missing_case_id']['imageBuffers'] as List<dynamic>)
                .map((imageUrl) => base64Decode(imageUrl))
                .toList();
        print(data);
        return MatchedPersonAddCompare(
          firstName: data['firstName'],
          lastName: data['lastName'],
          middleName: data['middleName'],
          age: data['age'],
          skinColor: data['skin_color'],
          photos: imageBuffers,
          phoneNumber: '123-456-7890', // Placeholder
          lastSeenPlace: data['description'],
        );
      }).toList();
      return matchedPeople;
    } else {
      print(
          'Failed to fetch matched people, status code: ${response.statusCode}');
      throw Exception('Failed to fetch matched people');
    }
  } catch (error) {
    print('Error fetching matched people: $error');
    throw Exception('Error fetching matched people');
  }
}
