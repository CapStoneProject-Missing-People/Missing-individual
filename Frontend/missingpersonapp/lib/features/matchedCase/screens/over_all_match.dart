import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/features/matchedCase/provider/desc_match_provider.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/existing_case_screen.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/new_case_screen.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';

class OverAllMatch extends StatefulWidget {
  const OverAllMatch({super.key});

  @override
  _OverAllMatchState createState() => _OverAllMatchState();
}

class _OverAllMatchState extends State<OverAllMatch> {
  @override
  void initState() {
    super.initState();
    final matchedCaseProvider = Provider.of<MatchedCaseProvider>(context, listen: false);
    final descriptionMatchProvider = Provider.of<DescriptionMatchProvider>(context, listen: false);

    Future.wait([
      matchedCaseProvider.fetchMatchedCases(),
      descriptionMatchProvider.fetchMatches(),
    ]).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    });
  }

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
              Consumer2<MatchedCaseProvider, DescriptionMatchProvider>(
                builder: (context, matchedCaseProvider, descriptionMatchProvider, child) {
                  if (matchedCaseProvider.isLoading || descriptionMatchProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                  } else if (matchedCaseProvider.hasError || descriptionMatchProvider.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading data.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  } else {
                    final matchedCases = matchedCaseProvider.matchedCases;
                    final descriptionMatches = descriptionMatchProvider.matches;

                    final similarCases = [];
                    for (var matchedCase in matchedCases) {
                      for (var descriptionMatch in descriptionMatches) {
                        if (matchedCase.id == descriptionMatch.existingCaseDetails?.missingCaseId.id) {
                          similarCases.add({
                            'matchedCase': matchedCase,
                            'descriptionMatch': descriptionMatch,
                          });
                        }
                      }
                    }

                    if (similarCases.isEmpty) {
                      return const Center(
                        child: Text(
                          'No similar cases found.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: similarCases.length,
                      itemBuilder: (context, index) {
                        final matchedCase = similarCases[index]['matchedCase'];
                        final descriptionMatch = similarCases[index]['descriptionMatch'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewCaseDetailsScreen(
                                          newCaseDetails: descriptionMatch.newCaseDetails!,
                                          matchingStatus: descriptionMatch.matchingStatus,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
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
                                      padding: const EdgeInsets.all(12.0),
                                      child: ExistingCaseListTile(
                                        caseDetails: descriptionMatch.existingCaseDetails!,
                                        matchingStatus: descriptionMatch.matchingStatus,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewCaseDetailsScreen(
                                                newCaseDetails: descriptionMatch.newCaseDetails!,
                                                matchingStatus: descriptionMatch.matchingStatus,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
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
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(
                                            matchedCase.imageBuffers[0],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 150,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'ID: ${matchedCase.id}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Status: ${matchedCase.status}',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        Text(
                                          'Matches: ${matchedCase.matches.length}',
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
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
