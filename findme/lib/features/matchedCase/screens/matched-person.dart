import 'package:findme/features/matchedCase/data/fetch-matched.dart';
import 'package:flutter/material.dart';
import 'package:findme/features/matchedCase/models/matched-person-model.dart';
import 'package:findme/features/matchedCase/screens/matched-person-card.dart.dart';
//matched missing person

class MissingPersonMatchPage extends StatelessWidget {
  final Future<List<MissingPersonAdd>> missingPersonsFuture =
      fetchMatchedPeople();

  MissingPersonMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Missing Persons'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<MissingPersonAdd>>(
        future: missingPersonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No missing persons found.'));
          } else {
            final missingPersons = snapshot.data!;
            missingPersons.sort((a, b) {
              double aMatchPercentage = calculateMatchPercentage(a);
              double bMatchPercentage = calculateMatchPercentage(b);
              return bMatchPercentage.compareTo(aMatchPercentage);
            });

            return Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: missingPersons.length,
                itemBuilder: (context, index) {
                  final missingPerson = missingPersons[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: MissingPersonCard(missingPerson: missingPerson),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

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
}
