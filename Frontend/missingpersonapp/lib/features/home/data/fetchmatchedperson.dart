import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'dart:typed_data';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<MissingPerson> fetchmatchCase(String caseID) async {
  print('the id: ' + caseID);
  final response = await http.get(
    Uri.parse("${Constants.postUri}/api/get-match/$caseID",),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body)['response'];
    
    final List<Uint8List> imageBuffers =
        (jsonData['missing_case_id']['imageBuffers'] as List<dynamic>)
            .map((imageUrl) => base64Decode(imageUrl))
            .toList();
          print('the data is: ' + jsonData.toString());
    return MissingPerson(
            name: jsonData['name']['firstName'] ?? '',
            middleName: jsonData['name']['middleName'] ?? '',
            lastName: jsonData['name']['lastName'] ?? '',
            gender: jsonData['gender'] ?? '',
            age: jsonData['age'] ?? 0,
            posterName: jsonData['user_id']['name'] ?? '',
            posterEmail: jsonData['user_id']['email'] ?? '',
            posterPhone: jsonData['user_id']['phoneNo'] ?? '',
            poster_id: jsonData['user_id']['_id'] ?? '',
            id: jsonData['_id'] ?? '',
            skin_color: jsonData['skin_color'] ?? '',
            lastSeenLocation: jsonData['lastSeenLocation'] ?? '',
            upperClothColor: jsonData['upperClothColor'] ?? '',
            upperClothType: jsonData['upperClothType'] ?? '',
            lowerClothColor: jsonData['lowerClothColor'] ?? '',
            lowerClothType: jsonData['lowerClothType'] ?? '',
            status: jsonData['missing_case_id']['status'] ?? '',
            dateReported: jsonData['missing_case_id']['dateReported'] ?? '',
            photos: imageBuffers,
            description: jsonData['description'] ?? '',
            medicalInformation: jsonData['medicalInformation'] ?? '',
            timeSinceDisappearance: jsonData['timeSinceDisappearance'] ?? 0,
            circumstanceOfDisappearance: jsonData['circumstanceOfDisappearance'] ?? '',
            bodySize: jsonData['bodySize'] ?? '',
          );
  } else {
    throw Exception('Failed to fetch the case');
  }
}
