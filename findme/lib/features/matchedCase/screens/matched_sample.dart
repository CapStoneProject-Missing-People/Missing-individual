import 'dart:typed_data';

import 'package:findme/features/compare/model/compare-model.dart';
import 'package:flutter/material.dart';
import 'package:findme/features/matchedCase/models/matched-person-model.dart';
import 'package:findme/features/missingPersonDetail/screens/missing_person_detail.dart';

class MatchedSamplePage extends StatelessWidget {
  final MissingPersonAdd missingPerson;

  const MatchedSamplePage(
      {super.key,
      required this.missingPerson,
      required MatchedPersonAdd matchedPerson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(missingPerson.firstName),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Image.memory(
              missingPerson.photos.isNotEmpty
                  ? missingPerson.photos[0]
                  : Uint8List(0), // Display placeholder if photos list is empty
              fit: BoxFit.cover, // Ensure the image covers the container
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missingPerson.firstName,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPercentageRow(
                      'First Name Percentage:', missingPerson.firstNameMatch),
                  _buildPercentageRow(
                      'Last Name Percentage:', missingPerson.lastNameMatch),
                  _buildPercentageRow(
                      'Middle Name Percentage:', missingPerson.middleNameMatch),
                  _buildPercentageRow(
                      'Age Percentage:', missingPerson.ageMatch),
                  _buildPercentageRow(
                      'Skin Color percentage:', missingPerson.skinColorMatch),
                  _buildPercentageRow('Upper Cloth Color percentage:',
                      missingPerson.upperclothColorMatch),
                  _buildPercentageRow('Upper Cloth Type percentage:',
                      missingPerson.upperclothTypeMatch),
                  _buildPercentageRow('Lower Cloth Color percentage:',
                      missingPerson.lowerclothColorMatch),
                  _buildPercentageRow('Lower Cloth Type percentage:',
                      missingPerson.lowerclothTypeMatch),
                  _buildPercentageRow('Eye Description percentage:',
                      missingPerson.eyeDescriptionMatch),
                  _buildPercentageRow('Nose Description Percentage:',
                      missingPerson.noseDescriptionMatch),
                  _buildPercentageRow('Hair Description Percentage:',
                      missingPerson.hairDescriptionMatch),
                  _buildPercentageRow('Last Seen Location Percentage:',
                      missingPerson.lastSeenLocationMatch),
                  _buildPercentageRow(
                      'Body Size Percentage:', missingPerson.bodySizeMatch),
                  _buildPercentageRow('Last Address Description Percentage:',
                      missingPerson.lastAddressDescriptionMatch),
                  _buildPercentageRow('Last Time Seen percentage:',
                      missingPerson.lastTimeSeenMatch),
                  if (missingPerson.medicalInformationMatch != null)
                    _buildPercentageRow('Medical Information percentage:',
                        missingPerson.medicalInformationMatch!),
                  if (missingPerson.circumstancesOfDisapperanceMatch != null)
                    _buildPercentageRow(
                        'Circumstance of Disapperance Percentage:',
                        missingPerson.circumstancesOfDisapperanceMatch!),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MissingPersonDetails(missingPerson: missingPerson),
                    ),
                  );
                },
                child: const Text('View Profile'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageRow(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label ${percentage.toStringAsFixed(2)}%',
          style: const TextStyle(fontSize: 16)),
    );
  }
}
