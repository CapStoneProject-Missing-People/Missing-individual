import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/authentication/models/missing_person_model.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissingPersonProvider extends ChangeNotifier {
  List<MissingPersonSpecific> _missingPersons = [];

  final User user;

  MissingPersonProvider(this.user);

  List<MissingPersonSpecific> get missingPersons => _missingPersons;

  Future<void> fetchMissingPersons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final http.Response response = await http.get(
      Uri.parse('${Constants.postUri}/api/features/getOwnFeatures'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(response.body.runtimeType);
      final List<dynamic> data = jsonDecode(response.body);
      print(data);

      if (data.isNotEmpty) {
        _missingPersons = data.map((item) {
          return MissingPersonSpecific.fromJson(item);
        }).toList();
      } else {
        _missingPersons = [];
      }
      notifyListeners();
    } else {
      throw Exception('Failed to load missing persons');
    }
  }

  /* void removeMissingPerson(MissingPerson person) {
    _missingPersons.remove(person);
    notifyListeners();
  } */
  Future<void> removeMissingPerson(MissingPersonSpecific missingPerson) async {
    int timeSinceDisappearance;
    if (missingPerson.featureType == 'feature_gt_2') {
      timeSinceDisappearance = 4; // Example value greater than 2
    } else {
      timeSinceDisappearance =
          2; // Default value if featureType is not 'feature_gt_2'
    }

    final url = Uri.parse(
        '${Constants.postUri}/api/features/delete/${missingPerson.id}?timeSinceDisappearance=${timeSinceDisappearance}');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authorization');

      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        // Successfully deleted from the server
        _missingPersons.remove(missingPerson);
        notifyListeners();
      } else {
        // Handle server errors
        throw Exception('Failed to delete the missing person');
      }
    } catch (error) {
      // Handle network errors or other issues
      throw Exception('Failed to delete the missing person: $error');
    }
  }

  Future<void> updateMissingPersonField(
      MissingPersonSpecific missingPerson, String field, String newValue) async {
    switch (field) {
      case 'First Name':
        missingPerson.name.firstName = newValue;
        break;
      case 'Last Name':
        missingPerson.name.lastName = newValue;
        break;
      case 'Age':
        missingPerson.age = int.tryParse(newValue) ?? missingPerson.age;
        break;
      case 'Last Seen Place':
        missingPerson.lastSeenLocation = newValue;
        break;
      case 'Phone Number':
        missingPerson.phoneNumber = newValue;
        break;
      case 'Description':
        missingPerson.description = newValue;
        break;
      case 'Gender':
        missingPerson.gender = newValue;
        break;
      case 'Skin Color':
        missingPerson.skin_color = newValue;
        break;
      case 'Body Size':
        missingPerson.body_size = newValue;
        break;
      case 'Upper Cloth Type':
        missingPerson.clothing.upper.clothType = newValue;
        break;
      case 'Upper Cloth Color':
        missingPerson.clothing.upper.clothColor = newValue;
        break;
      case 'Lower Cloth Type':
        missingPerson.clothing.lower.clothType = newValue;
        break;
      case 'Lower Cloth Color':
        missingPerson.clothing.lower.clothColor = newValue;
        break;
      default:
        return;
    }

    // Determine the timeSinceDisappearance
    int timeSinceDisappearance;
    if (missingPerson.featureType == 'feature_gt_2') {
      timeSinceDisappearance = 4; // Example value greater than 2
    } else {
      timeSinceDisappearance =
          2; // Default value if featureType is not 'feature_gt_2'
    }

    String toCamelCase(String str) {
      List<String> parts = str.split(' ');
      if (parts.length >= 2) {
        String camelCaseStr = parts[0].toLowerCase();
        for (int i = 1; i < parts.length; i++) {
          camelCaseStr += parts[i].substring(0, 1).toUpperCase() +
              parts[i].substring(1).toLowerCase();
        }
        return camelCaseStr;
      }
      str = str.toLowerCase();
      return str; // Return the original string if it has fewer than two parts
    }

    // Prepare the data to send to the update API
    final updatedTerm = newValue;
    final updatedBy = toCamelCase(field);
    final updateData = {'updateBy': updatedBy, 'updateTerm': updatedTerm};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    print(user.id);
    print(token);
    print(missingPerson.featureId);
    print(updatedBy);
    print(updatedTerm);

    // API call to update the missing person field
    final url = Uri.parse(
        '${Constants.postUri}/api/features/updateFeature/${missingPerson.id}?timeSinceDisappearance=${timeSinceDisappearance}');

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(updateData),
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      // Update was successful, notify listeners
      print("updated succesfully");
      notifyListeners();
    } else {
      // Handle error response
      throw Exception('Failed to update missing person');
    }
  }
}
