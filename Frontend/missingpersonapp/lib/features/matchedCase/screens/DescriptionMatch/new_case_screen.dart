import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';

extension CaseDetailsExtension on CaseDetails {
  MissingPerson toMissingPerson() {
    return MissingPerson(
      name: firstName,
      middleName: middleName,
      lastName: lastName,
      poster_id: userId,
      id:id,
      posterEmail: 'unknown',
      posterPhone: 'unknown',
      posterName: 'unknown',
      lastSeenLocation: 'unknown',
      timeSinceDisappearance: 0,
      age: age,
      upperClothColor: "unknown",
      upperClothType: "unknown",
      lowerClothColor: "unknown",
      lowerClothType: "unknown",
      gender: gender,
      skin_color: skinColor,
      status: "unknown",
      dateReported: "unknown",
      medicalInformation: "unknown",
      circumstanceOfDisappearance: "unknown",
      photos: missingCaseId.imageBuffers,
      description: description,
      bodySize: bodySize
        );
      }
    }

    class NewCaseDetailsScreen extends StatelessWidget {
      final CaseDetails newCaseDetails;
      final MatchingStatus matchingStatus;

      NewCaseDetailsScreen({
        required this.newCaseDetails,
        required this.matchingStatus,
      });

      @override
      Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('New Case Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          color: Color.fromARGB(255, 254, 255, 255),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                  child: CarouselSlider(
                    items: newCaseDetails.missingCaseId.imageBuffers.map((buffer) {
                      return Image.memory(buffer, fit: BoxFit.cover, width: double.infinity);
                    }).toList(),
                    options: CarouselOptions(
                      height: 200,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' ${newCaseDetails.firstName} ${newCaseDetails.middleName} ${newCaseDetails.lastName}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Age: ${newCaseDetails.age}', style: TextStyle(fontSize: 16)),
                      Text('Skin Color: ${newCaseDetails.skinColor}', style: TextStyle(fontSize: 16)),
                      Text('Description: ${newCaseDetails.description}', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      const Text('Matching Scores:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        MatchingScore(label: 'Age Score', value: matchingStatus.age),
                        MatchingScore(label: 'Skin Color Score', value: matchingStatus.skinColor),
                        MatchingScore(label: 'Description Score', value: matchingStatus.description),
                        MatchingScore(label: 'First Name Score', value: matchingStatus.firstName),
                        MatchingScore(label: 'Middle Name Score', value: matchingStatus.middleName),
                        MatchingScore(label: 'Last Name Score', value: matchingStatus.lastName),
                        MatchingScore(label: 'Gender Score', value: matchingStatus.gender),
                        MatchingScore(label: 'Body Size Score', value: matchingStatus.bodySize),
                        MatchingScore(label: 'Last Seen Location Score', value: matchingStatus.lastSeenLocation),
                        MatchingScore(label: 'Medical Information Score', value: matchingStatus.medicalInformation),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MissingPersonDetails(
                                  missingPerson: newCaseDetails.toMissingPerson(),
                                  header: "Matched person details",
                                ),
                              ),
                            );
                          },
                          child: Text('See Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MatchingScore extends StatelessWidget {
  final String label;
  final int value;

  const MatchingScore({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: value > 80 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
