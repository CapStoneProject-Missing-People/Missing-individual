import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Fetch data once when the widget is initialized
    final matchedCaseProvider = Provider.of<MatchedCaseProvider>(context, listen: false);
    final descriptionMatchProvider = Provider.of<DescriptionMatchProvider>(context, listen: false);

    Future.wait([
      matchedCaseProvider.fetchMatchedCases(),
      descriptionMatchProvider.fetchMatches(),
    ]).catchError((error) {
      // Handle errors here if necessary
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Match'),
      ),
      body: Consumer2<MatchedCaseProvider, DescriptionMatchProvider>(
        builder: (context, matchedCaseProvider, descriptionMatchProvider, child) {
          if (matchedCaseProvider.isLoading || descriptionMatchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (matchedCaseProvider.hasError || descriptionMatchProvider.hasError) {
            return Center(child: Text('Error loading data.'));
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
              return Center(child: Text('No similar cases found.'));
            }

            return ListView.builder(
              itemCount: similarCases.length,
              itemBuilder: (context, index) {
                final matchedCase = similarCases[index]['matchedCase'];
                final descriptionMatch = similarCases[index]['descriptionMatch'];

                return Row(
                  children: [
                    Expanded(
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
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.memory(matchedCase.imageBuffers[0], fit: BoxFit.cover, width: double.infinity),
                              SizedBox(height: 10),
                              Text(
                                'ID: ${matchedCase.id}',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text('Status: ${matchedCase.status}'),
                              Text('Matches: ${matchedCase.matches.length}', style: TextStyle(color: Colors.blueAccent)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
