import 'package:flutter/material.dart';
import 'package:findme/features/matchedCase/models/missing_person1.dart';
import 'package:findme/features/matchedCase/screens/missing_person_card1.dart';
//matched missing person

class MissingPersonMatchPage extends StatelessWidget {
  final List<MissingPersonAdd> missingPersons = [
    MissingPersonAdd(
      name: 'John Doe',
      age: 30,
      lastSeenPlace: 'New York',
      photos: [
        "https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bWFufGVufDB8fDB8fHww",
        "https://plus.unsplash.com/premium_photo-1664533227571-cb18551cac82?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fG1hbnxlbnwwfHwwfHx8MA%3D%3D",
      ],
      phoneNumber: '123-456-7890',
      description: "Description about John Doe's last known details.",
      ageMatch: 90,
      skinColorMatch: 85,
      clothColorMatch: 80,
      uniqueFeatureMatch: 95,
      descriptionMatch: 88,
      eyeColorMatch: 75,
      bodySizeMatch: 85,
    ),
    MissingPersonAdd(
      name: 'bel del',
      age: 30,
      lastSeenPlace: 'New York',
      photos: [
        "https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bWFufGVufDB8fDB8fHww",
        "https://plus.unsplash.com/premium_photo-1664533227571-cb18551cac82?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fG1hbnxlbnwwfHwwfHx8MA%3D%3D",
      ],
      phoneNumber: '123-456-7890',
      description: "Description about John Doe's last known details.",
      ageMatch: 90,
      skinColorMatch: 99,
      clothColorMatch: 80,
      uniqueFeatureMatch: 95,
      descriptionMatch: 88,
      eyeColorMatch: 75,
      bodySizeMatch: 100,
    ),
    // Additional MissingPerson instances can be added here...
  ];

  MissingPersonMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort the list of missing persons based on the match percentage in descending order
    missingPersons.sort((a, b) {
      double aMatchPercentage = calculateMatchPercentage(a);
      double bMatchPercentage = calculateMatchPercentage(b);
      return bMatchPercentage.compareTo(aMatchPercentage);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Missing Persons'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
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
      ),
    );
  }

  double calculateMatchPercentage(MissingPersonAdd person) {
    double totalMatch = person.ageMatch +
        person.skinColorMatch +
        person.clothColorMatch +
        person.uniqueFeatureMatch +
        person.descriptionMatch +
        person.eyeColorMatch +
        person.bodySizeMatch;
    return totalMatch / 7; // Average of the match percentages
  }
}
