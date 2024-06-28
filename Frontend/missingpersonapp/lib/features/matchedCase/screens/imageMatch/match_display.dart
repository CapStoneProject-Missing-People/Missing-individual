import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/models/image_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/screens/imageMatch/detail-match.dart';
import 'package:missingpersonapp/features/matchedCase/utils/image_display.dart';

class MatchesDisplay extends StatelessWidget {
  final List<ImageMatch> matches;
  
  final dynamic personImage;
  
  final String id;

  const MatchesDisplay({required this.matches, required this.personImage, required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = (screenWidth / 100)
            .floor(); // Adjust the number of columns based on screen width

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio:
                0.7, // Adjust this ratio as needed to fit your content
          ),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailMatchPage(match: match, images: personImage,id: id),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                      child: ImageDisplay(
                        imageBytes: match.imageBuffer,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Match Similarity: ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: '${match.similarity.ceil()}%',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}