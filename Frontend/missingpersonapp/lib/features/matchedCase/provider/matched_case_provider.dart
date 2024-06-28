import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/matchedCase/models/image_match_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchedCaseProvider with ChangeNotifier {
  List<MatchedCase> _matchedCases = [];
  bool get isLoading => false;
  bool get hasError => false;

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
print('matched cases: ${data[0]}');
      _matchedCases = data.map<MatchedCase>((item) {
        return MatchedCase.fromJson(item);
      }).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load matched cases');
    }
  }

  Future<void> updateStatusToFound(String id, String matchid) async {
    print('the ids are: ${id} and ${matchid}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');

    final response = await http.put(
      Uri.parse('${Constants.postUri}/api/change-staus-found/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': 'found', 'caseId': id, 'matchid': matchid}),
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
  Future<void> deleteMatchedCase(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');

    final response = await http.delete(
      Uri.parse('${Constants.faceApi}/delete-match/$id'),
    );

    if (response.statusCode == 200) {
      // Remove the deleted matched case from the local list
      _matchedCases.removeWhere((caseItem) => caseItem.id == id);

      notifyListeners();
    } else {
      throw Exception('Failed to delete matched case');
    }
  }
}
