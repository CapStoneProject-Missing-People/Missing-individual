import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/matchedCase/models/image-match-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchedCaseProvider with ChangeNotifier {
  List<MatchedCase> _matchedCases = [];

  List<MatchedCase> get matchedCases => _matchedCases;

  Future<void> fetchMatchedCases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');

    final response = await http.get(
      Uri.parse('${Constants.postUri}/api/get-missing-person'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('matched data: ${data[1]['matches'][0]}');

      _matchedCases = data.map((item) {
        print("missing people $item");
        List<Uint8List> decodeImageBuffers(List<dynamic> imageBuffers) {
          return imageBuffers
              .map((imageUrl) => base64Decode(imageUrl))
              .toList();
        }

        List<Map<String, dynamic>> decodeMatches(List<dynamic> matches) {
          return matches.map((match) {
            print("matched people $match");
            List<Uint8List> matchImageBuffers =
                decodeImageBuffers(match['imageBuffers']);
            return {
              'id': match['id'],
              'userID': match['userID'],
              'status': match['status'],
              'imageBuffers': matchImageBuffers,
            };
          }).toList();
        }

        return MatchedCase(
          id: item['_id'],
          userID: item['userID'],
          status: item['status'],
          imageBuffers: decodeImageBuffers(item['imageBuffers']),
          faceFeatureCreated: item['faceFeatureCreated'],
          dateReported: DateTime.parse(item['dateReported']),
          matches: decodeMatches(item['matches']),
        );
      }).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load matched cases');
    }
  }
}
