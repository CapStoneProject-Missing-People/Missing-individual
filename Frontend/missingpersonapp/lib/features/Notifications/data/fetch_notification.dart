import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

Future<MissingPerson> fetchCaseFromApiByID(String caseID) async {
  final response = await http.get(
    Uri.parse("${Constants.postUri}/api/features/getSingle/$caseID"),
  );
  print("fetched data for $caseID");
  print(response.statusCode);
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    List<Uint8List> imageBuffers = [];
    if (jsonData['missing_case_id'] != null &&
        jsonData['missing_case_id']['imageBuffers'] != null) {
      imageBuffers =
          (jsonData['missing_case_id']['imageBuffers'] as List<dynamic>)
              .map((imageUrl) => base64Decode(imageUrl))
              .toList();
    }

    return MissingPerson(
      id: jsonData['_id'] as String,
      userId: jsonData['user_id'] as String,
      name: Name(
        firstName: jsonData['name']['firstName'] as String,
        middleName: jsonData['name']['middleName'] as String,
        lastName: jsonData['name']['lastName'] as String,
      ),
      gender: jsonData['gender'] as String,
      age: jsonData['age'] as int,
      photos: imageBuffers,
      skinColor: jsonData['skin_color'] as String,
      clothing: Clothing(
        upper: UpperClothing(
          clothType: jsonData['clothing']['upper']['clothType'] as String,
          clothColor: jsonData['clothing']['upper']['clothColor'] as String,
        ),
        lower: LowerClothing(
          clothType: jsonData['clothing']['lower']['clothType'] as String,
          clothColor: jsonData['clothing']['lower']['clothColor'] as String,
        ),
      ),
      bodySize: jsonData['body_size'] as String,
      description: jsonData['description'] as String,
      timeSinceDisappearance: jsonData['timeSinceDisappearance'] as int,
      inputHash: jsonData['inputHash'] as String,
      version: jsonData['__v'] as int,
      missingCaseId: MissingCaseId(
        id: jsonData['missing_case_id']['_id'] as String,
        status: jsonData['missing_case_id']['status'] as String,
        imageBuffers: List<String>.from(
            jsonData['missing_case_id']['imageBuffers'] as List),
      ),
    );
  } else {
    throw Exception('Failed to fetch the case');
  }
}
