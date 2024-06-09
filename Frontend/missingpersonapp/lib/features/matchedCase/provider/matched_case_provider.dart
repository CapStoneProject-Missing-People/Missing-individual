import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/matchedCase/models/image_match_model.dart';
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
      List<dynamic> data = jsonDecode(response.body)['data'];
      _matchedCases = data.map<MatchedCase>((item) {
        return MatchedCase.fromJson(item);
      }).toList();

      notifyListeners();
    } else {
      throw Exception('Failed to load matched cases');
    }
  }

  Future<void> updateStatusToFound(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');

    final response = await http.put(
      Uri.parse('${Constants.postUri}/api//change-staus-found/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': 'found'}),
    );

    if (response.statusCode == 200) {
      // Update the local list of matched cases
      _matchedCases = _matchedCases.map((caseItem) {
        if (caseItem.id == id) {
          caseItem.status = 'found';
        }
        return caseItem;
      }).toList();

      notifyListeners();
    } else {
      throw Exception('Failed to update status');
    }
  }
}
