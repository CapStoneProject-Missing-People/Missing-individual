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

  Future<void> fetchMissingPersons() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _missingPersons = await fetchMissingPeople();
    } catch (e) {
      _errorMessage = 'Failed to fetch missing persons';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
