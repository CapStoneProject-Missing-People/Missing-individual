import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/service/missing_person_match_service.dart';

class DescriptionMatchProvider with ChangeNotifier {
  final DescriptionMatchService apiService;
  List<PotentialMatch> _matches = [];
  bool _isLoading = false;
  bool get hasError => false;

  DescriptionMatchProvider({required this.apiService});

  List<PotentialMatch> get matches => _matches;
  bool get isLoading => _isLoading;
  

  Future<void> fetchMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      _matches = await apiService.getPotentialMatches();
      print('Matches in fetchMatches: $_matches');
    } catch (e) {
      print('Error fetching matches: $e'); // Add error logging
      // Handle errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}