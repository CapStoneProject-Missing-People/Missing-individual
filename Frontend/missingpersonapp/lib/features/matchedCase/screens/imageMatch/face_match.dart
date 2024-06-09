import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/screens/imageMatch/match_display.dart';
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
                return ListView.builder(
                  itemCount: matchedCaseProvider.matchedCases.length,
                  itemBuilder: (context, index) {
                    final person = matchedCaseProvider.matchedCases[index];
                    return person.matches.isNotEmpty
                        ? CustomExpansionTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ImageDisplay(
                                    imageBytes: person.imageBuffers[0],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text('ID: ${person.id}'),
                                  if (person.status == 'pending')
                                    const Text('Potential', style: TextStyle(color: Colors.blue)),
                                  if (person.status == 'found')
                                    const Text('Found', style: TextStyle(color: Colors.green)),
                                  if (person.status == 'missing')
                                    const Text('Missing', style: TextStyle(color: Colors.red)),
                                  Text('${person.matches.length}', style: const TextStyle(color: Colors.blueAccent)),
                                ],
                            ),
                            children: [
                              MatchesDisplay(matches: person.matches, personImage: person.imageBuffers, id: person.id),
                            ],
                          )
                        : ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ImageDisplay(
                                  imageBytes: person.imageBuffers[0],
                                ),
                                const SizedBox(height: 8.0),
                                Text('ID: ${person.id}'),
                                if (person.status == 'pending')
                                  const Text('Potential', style: TextStyle(color: Colors.blue)),
                                if (person.status == 'found')
                                  const Text('Found', style: TextStyle(color: Colors.green)),
                                if (person.status == 'missing')
                                  const Text('Missing', style: TextStyle(color: Colors.red)),
                                Text('${person.matches.length}', style: const TextStyle(color: Colors.blueAccent)),
                              ],
                            ),
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

class CustomExpansionTile extends StatelessWidget {
  final Widget title;
  final List<Widget> children;

  const CustomExpansionTile({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 2.0, // Change the thickness here
            color: Colors.blueAccent, // Change the color here
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ExpansionTile(
            title: title,
            children: children,
          ),
        ),
        
      ],
    );
  }
}
