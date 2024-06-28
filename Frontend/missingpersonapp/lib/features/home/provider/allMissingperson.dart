import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/home/data/missing_person_fetch.dart';

class AllMissingPeopleProvider extends ChangeNotifier {
  List<MissingPerson> _missingPersons = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<MissingPerson> get missingPersons => _missingPersons;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchMissingPersons(BuildContext context) async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      final List<MissingPerson> fetchedData = await fetchMissingPeople(context);
      print('Fetched data: $fetchedData');
      _setMissingPersons(fetchedData);
    } catch (e) {
      print('Error: $e');
      _setErrorMessage(_getErrorMessage(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setErrorMessage(String message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      notifyListeners();
    }
  }

  void _setMissingPersons(List<MissingPerson> persons) {
    if (_missingPersons != persons) {
      _missingPersons = persons;
      notifyListeners();
    }
  }

  Widget getErrorMessageWidget() {
    return _errorMessage.isNotEmpty
        ? Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  String _getErrorMessage(dynamic e) {
    print("This is from get: " + e);
    if (e == "Exception: The connection has timed out. Please try again later.") {
      return 'Request timed out. Please try again later.';
    } else if (e == "Exception: No Internet connection. Please check your network settings.") {
      return 'No internet connection. Please check your network settings.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}