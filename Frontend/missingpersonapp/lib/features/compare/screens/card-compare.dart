import 'package:missingpersonapp/features/compare/model/compare-model.dart';
import 'package:missingpersonapp/features/compare/screens/detail-matched.dart';
import 'package:flutter/material.dart';

class CompareMatchedPersonCard extends StatelessWidget {
  final FeatureCompare featureCompare;
  final String userId;

  CompareMatchedPersonCard({super.key, required this.featureCompare})
      : userId = featureCompare.id; // Assigning userId from missingPerson.id

  @override
  Widget build(BuildContext context) {
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
              builder: (context) => ComparedMatchedDetails(userId: userId),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'firstName: ${featureCompare.firstNameMatch}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'middleName: ${featureCompare.middleNameMatch}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'lastName: ${featureCompare.lastNameMatch}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'gender: ${featureCompare.genderMatch}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'skinColor: ${featureCompare.skinColorMatch}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'lastSeenLocation: ${featureCompare.lastSeenLocationMatch}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'medical information: ${featureCompare.medicalInformationMatch}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'circumstance of disappearance: ${featureCompare.circumstanceOfDisappearanceMatch}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'similarity score: ${featureCompare.similarityScore}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'aggregate similarity: ${featureCompare.aggregateSimilarity}%',
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
