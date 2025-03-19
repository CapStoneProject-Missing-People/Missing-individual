import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Import BuildContext
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';

class ProfileService {
  final AuthService _authService = AuthService();

  Future<bool> updateUserProfile({
    required BuildContext context, // Pass BuildContext as a parameter
    required User user,
  }) async {
    try {
      print('Trying to update profile');

      // Get a valid access token
      final accessToken = await _authService.getValidAccessToken(context);
      if (accessToken == null) {
        print('Access token is null or invalid');
        return false;
      }

      // Make the HTTP PUT request to update the profile
      final response = await http.put(
        Uri.parse('${Constants.postUri}/api/profile/update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'phoneNo': user.phoneNo,
        }),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Profile updated successfully');
        return true;
      } else {
        print('Failed to update profile: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> deleteUserProfile({
    required BuildContext context, // Pass BuildContext as a parameter
  }) async {
    try {
      // Get a valid access token
      final accessToken = await _authService.getValidAccessToken(context);
      if (accessToken == null) {
        print('Access token is null or invalid');
        return false;
      }

      // Make the HTTP DELETE request to delete the profile
      final response = await http.delete(
        Uri.parse('${Constants.postUri}/api/profile/delete'),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Profile deleted successfully');
        return true;
      } else {
        print('Failed to delete profile: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }
}
