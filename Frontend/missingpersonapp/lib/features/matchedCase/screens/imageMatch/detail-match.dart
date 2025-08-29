import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/features/matchedCase/models/image_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailMatchPage extends StatefulWidget {
  final ImageMatch match;
  final List<Uint8List> images;
  final String id;

  const DetailMatchPage({
    super.key,
    required this.match,
    required this.images,
    required this.id,
  });

  @override
  State<DetailMatchPage> createState() => _DetailMatchPageState();
}

class _DetailMatchPageState extends State<DetailMatchPage> {
  Future<void> _openMap(String lat, String long) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    try {
      await launch(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
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
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Person',
                      style: TextStyle(
                        fontSize: 18,
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
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(widget.images[index], height: 200, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Match',
                      style: TextStyle(
                        fontSize: 18,
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
                    Card(
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(widget.match.imageBuffer, height: 200, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID: ${widget.match.id}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    if (widget.match.location.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _openMap(
                            widget.match.location[0]['latitude'].toString(),
                            widget.match.location[0]['longitude'].toString(),
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on, color: Colors.blue, size: 32),
                                SizedBox(width: 5),
                                Text(
                                  'See location on map',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GlassmorphismButton(
                          onPressed: acceptMatch,
                          child: const Text(
                            'Accept Match',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GlassmorphismButton(
                          onPressed: declineMatch,
                          child: const Text(
                            'Decline Match',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
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

  void acceptMatch() async {
    try {
      await Provider.of<MatchedCaseProvider>(context, listen: false).updateStatusToFound(widget.id, widget.match.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match accepted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept match: $e')),
      );
    }
  }

  void declineMatch() async {
    try {
      await Provider.of<MatchedCaseProvider>(context, listen: false).deleteMatchedCase(widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match declined!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline match: $e')),
      );
    }
  }
}
