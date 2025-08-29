import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/provider/desc_match_provider.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/new_case_screen.dart';
import 'package:provider/provider.dart';

class ExistingCasesScreen extends StatefulWidget {
  const ExistingCasesScreen({super.key});

  @override
  State<ExistingCasesScreen> createState() => _ExistingCasesScreenState();
}

class _ExistingCasesScreenState extends State<ExistingCasesScreen> {
  @override
  void initState() {
    super.initState();
    final matchProvider = Provider.of<DescriptionMatchProvider>(context, listen: false);
    matchProvider.fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<DescriptionMatchProvider>(context);
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
              matchProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : matchProvider.matches.isEmpty
                      ? const Center(
                          child: Text(
                            'No matches found.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: matchProvider.matches.length,
                          itemBuilder: (context, index) {
                            final match = matchProvider.matches[index];
                            final existingCase = match.existingCaseDetails;

                            if (existingCase != null) {
                              return ExistingCaseListTile(
                                caseDetails: existingCase,
                                matchingStatus: match.matchingStatus,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewCaseDetailsScreen(
                                        newCaseDetails: match.newCaseDetails!,
                                        matchingStatus: match.matchingStatus,
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
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

class ExistingCaseListTile extends StatelessWidget {
  final CaseDetails caseDetails;
  final MatchingStatus matchingStatus;
  final VoidCallback onTap;

  const ExistingCaseListTile({
    super.key,
    required this.caseDetails,
    required this.matchingStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                caseDetails.missingCaseId.imageBuffers.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                        child: CarouselSlider(
                          items: caseDetails.missingCaseId.imageBuffers.map((buffer) {
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
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                Text(
                  '${caseDetails.firstName} ${caseDetails.middleName} ${caseDetails.lastName}',
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
                const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age: ${caseDetails.age}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    Text(
                      'ID: ${caseDetails.missingCaseId.id}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    Text(
                      'Skin Color: ${caseDetails.skinColor}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    Text(
                      'Similarity: ${matchingStatus.aggregateSimilarity}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: matchingStatus.aggregateSimilarity > 80 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
