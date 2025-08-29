import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/common/widget/image_display.dart';
import 'package:missingpersonapp/features/matchedCase/models/image_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/screens/imageMatch/detail-match.dart';

class MatchesDisplay extends StatelessWidget {
  final List<ImageMatch> matches;
  final dynamic personImage;
  final String id;

  const MatchesDisplay({required this.matches, required this.personImage, required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final crossAxisCount = (screenWidth / 150).floor();

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMatchPage(match: match, images: personImage, id: id),
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
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ImageDisplay(
                                    imageBytes: match.imageBuffer,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Match Similarity: ',
                                      style: TextStyle(color: Colors.white70),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
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
    );
  }
}