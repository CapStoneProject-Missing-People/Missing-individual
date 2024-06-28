import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/models/image_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailMatchPage extends StatefulWidget {
  final ImageMatch match;
  final List<Uint8List> images;
  final String id;

  DetailMatchPage({
    Key? key,
    required this.match,
    required this.images,
    required this.id,
  }) : super(key: key);

  @override
  State<DetailMatchPage> createState() => _DetailMatchPageState();
}

class _DetailMatchPageState extends State<DetailMatchPage> {
  Future<void> _openMap(String lat, String long) async {
    print('the logitude $long');
    print('the latitude $lat');
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
      appBar: AppBar(
        title: const Text('Matched Case Decision'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Person',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(widget.images[index], height: 200),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Match',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(widget.match.imageBuffer, height: 200),
              ),
            ),
            Text("id : ${widget.match.id}"),
            const SizedBox(height: 20),
            if (widget.match.location.isNotEmpty)
              if (widget.match.location.isNotEmpty)
              GestureDetector(
                        onTap: () {
                          _openMap(
                            widget.match.location[0]['latitude'].toString(),
                            widget.match.location[0]['longitude'].toString(),
                          );
                        },
                        child: Container(

                  height: 60,
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 32,),
                      SizedBox(width: 5),
                      
                        Text(
                          'See location on map',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18
                          ),
                        ),
                    
                        
                    ],
        )
                  ),
                ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                  ),
                  onPressed: acceptMatch,
                  child: const Text(
                    'Accept Match',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                  ),
                  onPressed: declineMatch,
                  child: const Text(
                    'Decline Match',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void acceptMatch() async {
    try {
      await Provider.of<MatchedCaseProvider>(context, listen: false)
          .updateStatusToFound(widget.id, widget.match.id);
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
        await Provider.of<MatchedCaseProvider>(context, listen: false)
            .deleteMatchedCase(widget.id);
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
