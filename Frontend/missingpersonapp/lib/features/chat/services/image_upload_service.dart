import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';

class ImageUploadService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> uploadImage(File imageFile) async {
    try {
      final token = await _secureStorage.read(key: Constants.accessTokenKey);
      if (token == null) throw Exception('Authentication required');

      final bytes = await imageFile.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        throw Exception('Image too large (max 2MB)');
      }

      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse('${Constants.postUri}/api/upload'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
          'contentType': 'image/${imageFile.path.split('.').last}',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['imageUrl'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
