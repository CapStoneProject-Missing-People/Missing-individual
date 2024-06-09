import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class CheckFaceProvider extends ChangeNotifier {
  String? _apiResult;
  bool _loading = false;
  String? _personId;
  String? _matchId;
  TextEditingController _contactController = TextEditingController();
  Position? _currentPosition;
  String? _shareLocationValue;

  String? get apiResult => _apiResult;
  bool get loading => _loading;
  String? get personId => _personId;
  String? get matchId => _matchId;
  TextEditingController get contactController => _contactController;
  Position? get currentPosition => _currentPosition;
  String? get shareLocationValue => _shareLocationValue;

  Future<String?> sendImageToAPI(String imagePath) async {
    String apiUrl = '${Constants.faceApi}/recognize';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('File1', imagePath));

      var streamedResponse = await request.send();
      var response = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        return response;
      } else {
        return "Error uploading image: ${streamedResponse.statusCode}";
      }
    } catch (e) {
      return "Exception while uploading image: $e";
    }
  }

  void handleApiResponse(String response) {
    try {
      final parsedResponse = jsonDecode(response);
      final personId = parsedResponse['person_id'];
      final matchId = parsedResponse['matchId'];
      print('match id $matchId');
      _personId = personId != 'unknown' ? personId : null;
      _matchId = matchId;
      _apiResult = personId != 'unknown'
          ? 'You have found a missing person.\n please Enter the Information below'
          : 'Person not recognized.';

      notifyListeners();
    } catch (e) {
      _apiResult = 'Error parsing response.';
      notifyListeners();
    }
  }

  Future<void> shareLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    ;
    LocationPermission permission;

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.transparent,
            content: Text(
                'Location services are disabled. Please enable location services in your device settings.',
                style: TextStyle(color: Colors.red))),
      );
      // Open device settings to enable location services
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.transparent,
              content: Text('Location permissions are denied.',
                  style: TextStyle(color: Colors.red))),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.transparent,
        content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
            style: TextStyle(color: Colors.red)),
      ));
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _currentPosition = position;

    final contactInfo = _contactController.text;
    _shareLocationValue =
        'Contact Info: $contactInfo\nLocation: ${position.latitude}, ${position.longitude}';

    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content:
            Text(_shareLocationValue!, style: TextStyle(color: Colors.green)),
      ),
    );
  }

  Future<void> updateMatch(BuildContext context) async {
    if (_personId != null &&
        _contactController.text.isNotEmpty &&
        _shareLocationValue != null) {
      String apiUrl = '${Constants.faceApi}/update-match-info';
      print("match id in update: $matchId");
      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'matchId': _matchId,
            'contact': _contactController.text,
            'location': {
              'latitude': _currentPosition?.latitude,
              'longitude': _currentPosition?.longitude,
            },
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.transparent,
              content: Text('Match updated successfully.',
                  style: TextStyle(color: Colors.green)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              content: Text('Error updating match: ${response.statusCode}',
                  style: TextStyle(color: Colors.red)),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            content: Text('Exception while updating match: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.transparent,
          content: Text(
              'Please ensure all fields are filled and location is shared.',
              style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
