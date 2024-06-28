import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';

Future<List<MissingPerson>> fetchMissingPeople(BuildContext context) async {
  try {
    // HTTP GET request with a timeout
    final response = await http.get(
      Uri.parse("${Constants.postUri}/api/features/getAll"),
    ).timeout(Duration(seconds: 65), onTimeout: () {
      throw TimeoutException("The connection has timed out, Please try again!"); // Throws TimeoutException
    });

    List<MissingPerson> missingPeople = [];

    // Handle the response
    httpErrorHandle(
      response: response,
      context: context,
      onSuccess: () {
        final List<dynamic> jsonData = json.decode(response.body);
        print("Raw JSON data: $jsonData");

        missingPeople = jsonData.map((dynamic item) {
          try {
            final Map<String, dynamic> data = item as Map<String, dynamic>;

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
              middleName: data['name']['middleName'] ?? '',
              lastName: data['name']['lastName'] ?? '',
              gender: data['gender'] ?? '',
              age: data['age'] ?? 0,
              posterName: data['user_id']['name'] ?? '',
              posterEmail: data['user_id']['email'] ?? '',
              posterPhone: data['user_id']['phoneNo'] ?? '',
              poster_id: data['user_id']['_id'] ?? '',
              id: data['_id'] ?? '',
              skin_color: data['skin_color'] ?? '',
              bodySize: data['body_size'] ?? '',
              lastSeenLocation: data['lastSeenLocation'] ?? '',
              upperClothColor: data['upperClothColor'] ?? '',
              upperClothType: data['upperClothType'] ?? '',
              lowerClothColor: data['lowerClothColor'] ?? '',
              lowerClothType: data['lowerClothType'] ?? '',
              status: data['missing_case_id']['status'] ?? '',
              dateReported: data['missing_case_id']['dateReported'] ?? '',
              photos: imageBuffers,
              description: data['description'] ?? '',
              medicalInformation: data['medicalInformation'] ?? '',
              timeSinceDisappearance: data['timeSinceDisappearance'] ?? '',
              circumstanceOfDisappearance: data['circumstanceOfDisappearance'] ?? '',
            );
          } catch (e) {
            print("Error mapping data item: $e");
            throw Exception("Error parsing data item: $e"); // Throws specific error encountered during data mapping
          }
        }).toList();

        print("Parsed missingPeople: $missingPeople");
      },
    );

    return missingPeople;
  } on SocketException catch (e) {
    print("No Internet connection: $e");
    throw Exception("No Internet connection. Please check your network settings."); // Throws SocketException
  } on TimeoutException catch (e) {
    print("Connection timeout: $e");
    throw Exception("The connection has timed out. Please try again later."); // Throws TimeoutException
  } catch (e) {
    print("Exception caught in fetchMissingPeople: $e");
    throw Exception("An unexpected error occurred: $e"); // Throws any other exceptions
  }
}