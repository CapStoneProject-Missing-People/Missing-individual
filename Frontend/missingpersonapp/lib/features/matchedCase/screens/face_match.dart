import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';

class MissingPersonImageMatch extends StatelessWidget {
  const MissingPersonImageMatch({Key? key});

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
                return ListView.builder(
                  itemCount: matchedCaseProvider.matchedCases.length,
                  itemBuilder: (context, index) {
                    final person =
                        matchedCaseProvider.matchedCases[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text('Missing Person: ${person.id}'),
                          subtitle:
                              Text('Matches: ${person.matches.length}'),
                        ),
                        if (person.imageBuffers.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Missing Person Images',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: person.imageBuffers.length,
                                  itemBuilder: (context, imgIndex) {
                                    final imageBuffer =
                                        person.imageBuffers[imgIndex];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.memory(imageBuffer), // Render the image from imageBuffer
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        if (person.matches.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Potential Matches',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: person.matches.length,
                                  itemBuilder: (context, matchIndex) {
                                    final match = person.matches[matchIndex];
                                    final matchImageBuffer =
                                        match['imageBuffer'];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Visibility(
                                        visible: matchImageBuffer != null,
                                        child: Image.memory(
                                            matchImageBuffer ?? Uint8List(0)),
                                        // Render the image from matchImageBuffer if available
                                      ),
                                    );
                                  },
                                ),
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
