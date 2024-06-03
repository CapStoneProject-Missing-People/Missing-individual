import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<List<MissingPerson>> fetchMissingPeople() async {
  try {
    // Make HTTP GET request to fetch data from the API endpoint
    final response = await http.get(
      Uri.parse("${Constants.postUri}/api/features/getAll"),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> jsonData = json.decode(response.body);

      // Debug print the raw JSON data
      print("Raw JSON data: $jsonData");

      // Map the parsed data to instances of MissingPerson class
      print("before result");

      List<MissingPerson> missingPeople = jsonData.map((data) {
        try {
          // Debug print the current data item
          print("Current data item: $data");

          // Check if missing_case_id is not null
          if (data['missing_case_id'] != null) {
            // Decode each base64 image string to Uint8List
            final List<Uint8List> imageBuffers = 
                (data['missing_case_id']['imageBuffers'] as List<dynamic>)
                    .map((imageUrl) => base64Decode(imageUrl))
                    .toList();

            print("Decoded image buffers for ${data['name']['firstName']}");

            return MissingPerson(
              name: data['name']['firstName'],
              age: data['age'],
              skin_color: data['skin_color'],
              photos: imageBuffers,
              phoneNo: '123-456-7890', // Temporary placeholder
              description: data['description'],
            );
          } else {
            print("missing_case_id is null for ${data['name']['firstName']}");
            return MissingPerson(
              name: data['name']['firstName'],
              age: data['age'],
              skin_color: data['skin_color'],
              photos: [],
              phoneNo: '123-456-7890', // Temporary placeholder
              description: data['description'],
            );
          }
        } catch (e) {
          print("Error mapping data item: $e");
          throw e;
        }
      }).toList();

      print("after result");
      return missingPeople;
    } else {
      // If the request fails, throw an exception or handle the error accordingly
      print('Failed to fetch missing people. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch missing people');
    }
  } catch (e) {
    print("Exception caught in fetchMissingPeople: $e");
    throw e;
  }
}
