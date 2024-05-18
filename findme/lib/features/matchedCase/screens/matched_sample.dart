import 'package:flutter/material.dart';
import 'package:findme/features/matchedCase/models/missing_person1.dart';
import 'package:findme/features/missingPersonDetail/screens/missing_person_detail1.dart';

class MatchedSamplePage extends StatelessWidget {
  final MissingPersonAdd missingPerson;

  const MatchedSamplePage({super.key, required this.missingPerson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(missingPerson.name),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Image.network(
              missingPerson.photos.first,
              width: double.infinity,
              fit: BoxFit.cover,
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
                    missingPerson.name,
                    style: const TextStyle (
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPercentageRow(
                      'Age Percentage:', missingPerson.ageMatch),
                  _buildPercentageRow('Skin Color percentage:',
                      missingPerson.skinColorMatch),
                  _buildPercentageRow('Cloth Color percentage:',
                      missingPerson.clothColorMatch),
                  _buildPercentageRow('Body Size percentage:',
                      missingPerson.bodySizeMatch),
                  _buildPercentageRow('Unique Feature percentage:',
                      missingPerson.uniqueFeatureMatch),
                  _buildPercentageRow('Eye Color percentage:',
                      missingPerson.eyeColorMatch),
                  _buildPercentageRow('Description percentage:',
                      missingPerson.descriptionMatch),
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
      child: Text('$label ${percentage.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 16)),
    );
  }
}
