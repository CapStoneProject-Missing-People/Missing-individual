import 'dart:typed_data';

import 'package:findme/features/matchedCase/models/matched-person-model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static String uri = 'http://192.168.188.100:4000';
  static String postUri = 'http://192.168.188.100:4000';
  static String faceApi = 'http://192.168.188.100:6000';
}

Future<List<MissingPersonAdd>> fetchMatchedPeople() async {
  print("Fetching missing people...");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authorization');

  final String url = "${Constants.postUri}/api/features/getAll";
  print("Request URL: $url");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> jsonData = json.decode(response.body);
      // Map the parsed data to instances of MissingPersonAdd class
      List<MissingPersonAdd> missingPeople = jsonData.map((data) {
        // Decode each base64 image string to Uint8List
        final List<Uint8List> imageBuffers =
            (data['missing_case_id']['imageBuffers'] as List<dynamic>)
                .map((imageUrl) => base64Decode(imageUrl))
                .toList();
        print(data);
        return MissingPersonAdd(
          firstName: data['firstName'],
          lastName: data['lastName'],
          middleName: data['middleName'],
          age: data['age'],
          skinColor: data['skin_color'],
          photos: imageBuffers,
          phoneNumber: '123-456-7890', // Placeholder
          eyeDescriptionMatch: data['description'],
          lastSeenPlace: data['description'],
          firstNameMatch: data['firstNameMatch'],
          middleNameMatch: data['middleNameMatch'],
          lastNameMatch: data['lastNameMatch'],
          ageMatch: data['ageMatch'],
          skinColorMatch: data['skinColorMatch'],
          upperclothColorMatch: data['upperclothColorMatch'],
          upperclothTypeMatch: data['upperclothTypeMatch'],
          lowerclothColorMatch: data['lowerclothColorMatch'],
          lowerclothTypeMatch: data['lowerclothTypeMatch'],
          noseDescriptionMatch: data['noseDescriptionMatch'],
          hairDescriptionMatch: data['hairDescriptionMatch'],
          lastSeenLocationMatch: data['lastSeenLocationMatch'],
          lastAddressDescriptionMatch: data['lastAddressDescriptionMatch'],
          lastTimeSeenMatch: data['lastTimeSeenMatch'],
          medicalInformationMatch: data['medicalInformationMatch'],
          circumstancesOfDisapperanceMatch:
              data['circumstancesOfDisapperanceMatch'],
          bodySizeMatch: data['bodySizeMatch'],
        );
      }).toList();
      return missingPeople;
    } else {
      print(
          'Failed to fetch missing people, status code: ${response.statusCode}');
      throw Exception('Failed to fetch missing people');
    }
  } catch (error) {
    print('Error fetching missing people: $error');
    throw Exception('Error fetching missing people');
  }
}
