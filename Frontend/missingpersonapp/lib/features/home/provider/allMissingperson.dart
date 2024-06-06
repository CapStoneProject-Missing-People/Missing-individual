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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final List<MissingPerson> fetchedData = await fetchMissingPeople();
      print('Fetched data: $fetchedData');
      _missingPersons = fetchedData;
    } catch (e) {
      print('Error: $e');
      _errorMessage = 'Failed to fetch missing persons';
    } finally {
      _isLoading = false;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
