import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'dart:typed_data';

import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<MissingPerson> fetchCaseFromApiByID(String caseID) async {
  final response = await http.get(
    Uri.parse("${Constants.postUri}/api/features/getSingle/$caseID"),
  );
  print("fetched data for $caseID");
  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final List<Uint8List> imageBuffers = (jsonData['missing_case_id']['imageBuffers'] as List<dynamic>)
        .map((imageUrl) => base64Decode(imageUrl))
        .toList();
    return MissingPerson(
      name: jsonData['name']['firstName'],
      age: jsonData['age'],
      userName: jsonData['user_id']['name'] ?? '',
      email: jsonData['user_id']['email'] ?? '',
      user_id: jsonData['user_id'],
      skin_color: jsonData['skin_color'],
      photos: imageBuffers,
      phoneNo: '123-456-7890', // Temporary placeholder
      description: jsonData['description'],
    );
  } else {
    throw Exception('Failed to fetch the case');
  }
}
