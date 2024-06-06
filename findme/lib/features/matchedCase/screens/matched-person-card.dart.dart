import 'dart:typed_data';

import 'package:findme/features/matchedCase/models/matched-person-model.dart';
import 'package:findme/features/missingPersonDetail/screens/missing_person_detail.dart';
import 'package:flutter/material.dart';

class MissingPersonCard extends StatelessWidget {
  final MissingPersonAdd missingPerson;

  const MissingPersonCard({super.key, required this.missingPerson});

  double calculateMatchPercentage(MissingPersonAdd person) {
    // Create a list of match fields
    List<double?> matchFields = [
      person.firstNameMatch,
      person.middleNameMatch,
      person.lastNameMatch,
      person.ageMatch,
      person.skinColorMatch,
      person.upperclothColorMatch,
      person.upperclothTypeMatch,
      person.lowerclothColorMatch,
      person.lowerclothTypeMatch,
      person.eyeDescriptionMatch,
      person.noseDescriptionMatch,
      person.hairDescriptionMatch,
      person.lastSeenLocationMatch,
      person.lastAddressDescriptionMatch,
      person.lastTimeSeenMatch,
      person.medicalInformationMatch,
      person.circumstancesOfDisapperanceMatch,
      person.bodySizeMatch,
    ];

    // Calculate total match and count non-null fields
    double totalMatch = 0;
    int fieldCount = 0;

    for (var match in matchFields) {
      if (match != null) {
        totalMatch += match;
        fieldCount++;
      }
    }

    // Avoid division by zero
    if (fieldCount == 0) return 0;

    // Calculate average match percentage
    return totalMatch / fieldCount;
  }

  @override
  Widget build(BuildContext context) {
    double matchPercentage = calculateMatchPercentage(missingPerson);

    return Material(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MissingPersonDetails(missingPerson: missingPerson),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Image.memory(
                missingPerson.photos.isNotEmpty
                    ? missingPerson.photos[0]
                    : Uint8List(
                        0), // Display placeholder if photos list is empty
                fit: BoxFit.cover, // Ensure the image covers the container
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${missingPerson.firstName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Age: ${missingPerson.age}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Last Seen Place: ${missingPerson.lastSeenPlace ?? 'N/A'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Phone Number: ${missingPerson.phoneNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Match Percentage: ${matchPercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
