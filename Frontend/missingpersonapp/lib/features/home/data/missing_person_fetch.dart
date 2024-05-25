import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<List<MissingPerson>> fetchMissingPeople() async {
  // Make HTTP GET request to fetch data from the API endpoint
  final response = await http.get(
    Uri.parse(
        "${Constants.postUri}/api/features/getAll"),
  );
  if (response.statusCode == 200) {
    // Parse the JSON response
    final List<dynamic> jsonData = json.decode(response.body);
    // Map the parsed data to instances of MissingPerson class
    List<MissingPerson> missingPeople = jsonData.map((data) {
      // Decode each base64 image string to Uint8List
      final List<Uint8List> imageBuffers =
          (data['missing_case_id']['imageBuffers'] as List<dynamic>)
              .map((imageUrl) => base64Decode(imageUrl))
              .toList();
      print(data);
      return MissingPerson(
        name: data['name']['firstName'],
        age: data['age'],
        skin_color: data['skin_color'],
        photos: imageBuffers,
        phoneNo: '123-456-7890',
        description: data['description'],
      );
    }).toList();

    return missingPeople;
  } else {
    // If the request fails, throw an exception or handle the error accordingly
    throw Exception('Failed to fetch missing people');
  }
}
