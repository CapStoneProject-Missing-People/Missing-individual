import 'dart:convert';
import 'package:http/http.dart' as http; // Import the http package
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DescriptionMatchService {
  Future<List<PotentialMatch>> getPotentialMatches() async {
    final apiUrl =
        Uri.parse('${Constants.postUri}/api/features/getPotentialMatch');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');

    final response = await http.get(
      apiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    print("status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['message'];
      var thedata = data.map((item) => PotentialMatch.fromJson(item)).toList();
      print('the data $thedata');
      return data.map((item) => PotentialMatch.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load potential matches');
    }
  }
}
