import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/home/data/fetchmatchedperson.dart';

class CaseMatchedProvider with ChangeNotifier {
  MissingPerson? _case;
  bool _isLoading = false;
  String _errorMessage = '';

  MissingPerson? get theCase => _case;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchCaseById(String caseID) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('inside');
      _case = await fetchmatchCase(caseID);
      _errorMessage = ''; // Clear any previous error message
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
