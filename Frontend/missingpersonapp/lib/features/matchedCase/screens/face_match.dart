import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/utils/image_display.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';

class MissingPersonImageMatch extends StatelessWidget {
  const MissingPersonImageMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Match'),
      ),
      body: FutureBuilder(
        future: Provider.of<MatchedCaseProvider>(context, listen: false)
            .fetchMatchedCases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<MatchedCaseProvider>(
              builder: (context, matchedCaseProvider, child) {
                for (var i = 0;
                    i < matchedCaseProvider.matchedCases.length;
                    i++) {
                  final person = matchedCaseProvider.matchedCases[i];
                  print('Matched Case $i: ${person.id}');
                  print('Status: ${person.status}');
                  print('Number of Matches: ${person.matches.length}');
                  print('the person buffer ${person.imageBuffers[0]}');
                  print("all the missing person data $person");
                  for (var match in person.matches) {
                    print('Match Distance: ${match.distance}');
                    print('Match Similarity: ${match.similarity}');
                    print("all the match data ${match}");
                    print('image buffer of match ${match.imageBuffer}');
                  }
                }

                return ListView.builder(
                  itemCount: matchedCaseProvider.matchedCases.length,
                  itemBuilder: (context, index) {
                    final person = matchedCaseProvider.matchedCases[index];
                    return Column(
                      children: [
                        ImageDisplay(
                          imageBytes: person.imageBuffers[0],
                        ),
                        const SizedBox(height: 8.0),
                        Text('ID: ${person.id}'),
                        Text('Status: ${person.status}'),
                        Text('Number of Matches: ${person.matches.length}'),
                        for (var match in person.matches)
                          Column(
                            children: [
                              Text('Match Distance: ${match.distance}'),
                              Text('Match Similarity: ${match.similarity}'),
                              ImageDisplay(
                                imageBytes: match.imageBuffer,
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
