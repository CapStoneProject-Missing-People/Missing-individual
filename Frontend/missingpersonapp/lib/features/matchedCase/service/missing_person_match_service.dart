import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';

class MissingPersonService {
  final String baseUrl = 'https://api.yourbackend.com';

  Future<List> fetchMissingPersons() async {
    final response = await http.get(Uri.parse('$baseUrl/missing-persons'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => MissingPersonDescMatch.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load missing persons');
    }
  }
}
