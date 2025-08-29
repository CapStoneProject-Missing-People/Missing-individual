import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';

extension CaseDetailsExtension on CaseDetails {
  MissingPerson toMissingPerson() {
    return MissingPerson(
      name: firstName,
      middleName: middleName,
      lastName: lastName,
      poster_id: userId,
      id: id,
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
      bodySize: bodySize,
    );
  }
}

class NewCaseDetailsScreen extends StatelessWidget {
  final CaseDetails newCaseDetails;
  final MatchingStatus matchingStatus;

  const NewCaseDetailsScreen({
    super.key,
    required this.newCaseDetails,
    required this.matchingStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.white.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                          child: CarouselSlider(
                            items: newCaseDetails.missingCaseId.imageBuffers.map((buffer) {
                              return Image.memory(
                                buffer,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
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
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${newCaseDetails.firstName} ${newCaseDetails.middleName} ${newCaseDetails.lastName}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Age: ${newCaseDetails.age}',
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                              Text(
                                'Skin Color: ${newCaseDetails.skinColor}',
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                              Text(
                                'Description: ${newCaseDetails.description}',
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Matching Scores:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
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
                                child: GlassmorphismButton(
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
                                  child: const Text(
                                    'See Details',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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
              Positioned(
                top: 10,
                left: 10,
                child: GlassmorphismButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
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
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
