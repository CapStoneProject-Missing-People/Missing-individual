import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/models/missing_person1.dart';
import 'package:missingpersonapp/features/matchedCase/provider/desc_match_provider.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/missing_person_card1.dart';
import 'package:provider/provider.dart';

class MissingPersonMatchPage extends StatelessWidget {
  MissingPersonMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DescriptionMatchProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Missing Persons'),
        backgroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: provider.missingPersons.length,
                itemBuilder: (context, index) {
                  final missingPerson = provider.missingPersons[index];
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
