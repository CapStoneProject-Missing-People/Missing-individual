import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/service/missing_person_match_service.dart';

class DescriptionMatchProvider with ChangeNotifier {
  final MissingPersonService _service = MissingPersonService();
  List<MissingPersonDescMatch> _missingPersons = [];
  bool _isLoading = false;

  List<MissingPersonDescMatch> get missingPersons => _missingPersons;
  bool get isLoading => _isLoading;

  Future<void> fetchMissingPersons() async {
    _isLoading = true;
    notifyListeners();

    try {
      _missingPersons = await _service.fetchMissingPersons() as List<MissingPersonDescMatch>;
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
