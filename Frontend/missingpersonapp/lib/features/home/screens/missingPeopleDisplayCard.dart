import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MissingPeopleDisplay extends StatelessWidget {
  final MissingPerson missingPerson;
  final List<TextSpan> highlightedName;
  final List<TextSpan> highlightedSkinColor;
  final List<TextSpan> highlightedAge;

  const MissingPeopleDisplay({
    super.key,
    required this.missingPerson,
    required this.highlightedName,
    required this.highlightedSkinColor,
    required this.highlightedAge,
  });

  Future<void> _shareMissingPerson(BuildContext context) async {
    final String shareContent = '''
Missing Person Details:
First Name: ${missingPerson.name}
Age: ${missingPerson.age}
    ''';

    List<XFile> files = [];

    if (missingPerson.photos.isNotEmpty) {
      Uint8List imageBytes = missingPerson.photos.first;
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/missing_person.png').create();
      await file.writeAsBytes(imageBytes);
      files.add(XFile(file.path));
    }

    await Share.shareXFiles(files, text: shareContent);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.1), // Glassmorphism effect
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MissingPersonDetails(
                  missingPerson: missingPerson,
                  header: "Missing Person Details"),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Gradient Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: missingPerson.photos.isNotEmpty
                        ? Image.memory(
                            missingPerson.photos[0],
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.white70,
                                size: 60,
                              ),
                            ),
                          ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      RichText(
                        text: TextSpan(
                          children: highlightedName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Age
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              children: highlightedAge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Skin Color
                      Row(
                        children: [
                          const Icon(
                            Icons.palette_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              children: highlightedSkinColor,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Phone Number
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              final url = 'tel:${missingPerson.posterPhone}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                              missingPerson.posterPhone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Share Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => _shareMissingPerson(context),
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
