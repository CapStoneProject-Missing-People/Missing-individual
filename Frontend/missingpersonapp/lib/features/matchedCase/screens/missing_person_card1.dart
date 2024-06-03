import 'package:missingpersonapp/features/matchedCase/models/missing_person1.dart'
    as mp;
import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/screens/matched_sample.dart';

class MissingPersonCard extends StatelessWidget {
  final mp.MissingPersonAdd missingPerson;

  const MissingPersonCard({super.key, required this.missingPerson});

  double calculateMatchPercentage(mp.MissingPersonAdd person) {
    double totalMatch = person.ageMatch +
        person.skinColorMatch +
        person.clothColorMatch +
        person.uniqueFeatureMatch +
        person.descriptionMatch +
        person.eyeColorMatch +
        person.bodySizeMatch;
    return totalMatch / 7; // Average of the match percentages
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
                  MatchedSamplePage(missingPerson: missingPerson),
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
              child: Image.network(
                missingPerson.photos.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${missingPerson.name}',
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
                    'Skin Color: ${missingPerson.skin_color}',
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
