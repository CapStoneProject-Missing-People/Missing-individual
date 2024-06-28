import 'dart:typed_data';
import 'package:missingpersonapp/features/compare/model/matched-compare.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<MatchedPersonCompare>> fetchMatchedPeople(
    String userId, int? lastTime) async {
  print("Fetching matched people for user ID: $userId...");

  final String url =
      "${Constants.postUri}/api/features/getSingleFeature/$userId/$lastTime";
  print("Request URL: $url");

  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    try {
      // Parse the JSON response
      final dynamic data = json.decode(response.body);

      // Print the type and structure of the data
      print("Decoded data type: ${data.runtimeType}");
      print("Decoded data: $data");

      return [MatchedPersonCompare.fromJson(data)];
    } catch (e) {
      print("Error decoding JSON: $e");
      throw Exception('Failed to parse response');
    }
  } else {
    throw Exception('Failed to load missing persons');
  }
}
