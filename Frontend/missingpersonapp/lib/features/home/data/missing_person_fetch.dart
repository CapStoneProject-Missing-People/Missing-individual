import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<List<MissingPerson>> fetchMissingPeople() async {
  try {
    final response = await http.get(
      Uri.parse("${Constants.postUri}/api/features/getAll"),
    );

    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print("Raw JSON data: $jsonData");

      List<MissingPerson> missingPeople = jsonData.map((dynamic item) {
        try {
          final Map<String, dynamic> data = item as Map<String, dynamic>;
          print("Current data item: $data");

          List<Uint8List> imageBuffers = [];
          if (data['missing_case_id'] != null && data['missing_case_id']['imageBuffers'] != null) {
            imageBuffers = (data['missing_case_id']['imageBuffers'] as List<dynamic>).map((imageUrl) {
              if (imageUrl is String) {
                return base64Decode(imageUrl);
              } else {
                print('Invalid image URL format: $imageUrl');
                return Uint8List(0); // Return an empty Uint8List in case of error
              }
            }).toList();
          }

          return MissingPerson(
            name: data['name']['firstName'] ?? '',
            age: data['age'] ?? 0,
            userName: data['user_id']['name'] ?? '',
            email: data['user_id']['email'] ?? '',
            user_id: data['user_id']['_id'] ?? '',
            skin_color: data['skin_color'] ?? '',
            photos: imageBuffers,
            phoneNo: '123-456-7890', // Temporary placeholder
            description: data['description'] ?? '',
          );
        } catch (e) {
          print("Error mapping data item: $e");
          throw e;
        }
      }).toList();

      print("Parsed missingPeople: $missingPeople");
      return missingPeople;
    } else {
      print('Failed to fetch missing people. Status code: ${response.statusCode}');
      throw Exception('Failed to fetch missing people');
    }
  } catch (e) {
    print("Exception caught in fetchMissingPeople: $e");
    throw e;
  }
}
