import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'dart:typed_data';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<MissingPerson> fetchmatchCase(String caseID) async {
  final response = await http.get(
    Uri.parse("${Constants.postUri}/api/get-match/$caseID",),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body)['response'];
    
    final List<Uint8List> imageBuffers =
        (jsonData['missing_case_id']['imageBuffers'] as List<dynamic>)
            .map((imageUrl) => base64Decode(imageUrl))
            .toList();
    return MissingPerson(
      missing_id: jsonData['missing_case_id']['_id'],
      name: jsonData['name']['firstName'],
      body_size: jsonData['body_size'],
      age: jsonData['age'],
      gender: jsonData['gender'],
      skin_color: jsonData['skin_color'],
      photos: imageBuffers,
      phoneNo: '123-456-7890', // Temporary placeholder
      description: jsonData['description'],
      status: jsonData['missing_case_id']['status'],
      date_reported: jsonData['missing_case_id']['dateReported'],
    );
  } else {
    throw Exception('Failed to fetch the case');
  }
}
