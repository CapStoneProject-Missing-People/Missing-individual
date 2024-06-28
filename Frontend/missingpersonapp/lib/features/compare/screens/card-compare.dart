/* import 'package:missingpersonapp/features/compare/model/compare-model.dart';
import 'package:missingpersonapp/features/compare/screens/detail-matched.dart';
import 'package:flutter/material.dart';

class CompareMatchedPersonCard extends StatelessWidget {
  final List<FeatureCompare> featureCompareList;
  final int? lastTimeSeen; // Add this line

  CompareMatchedPersonCard(
      {super.key,
      required this.featureCompareList,
      this.lastTimeSeen}); // Add lastTimeSeen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Persons'),
      ),
      body: ListView.builder(
        itemCount: featureCompareList.length,
        itemBuilder: (context, index) {
          final featureCompare = featureCompareList[index];
          final userId = featureCompare.id;

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildListTile(Icons.person,
                      'First Name: ${featureCompare.firstNameMatch}%'),
                  _buildListTile(Icons.person,
                      'Middle Name: ${featureCompare.middleNameMatch}%'),
                  _buildListTile(Icons.person,
                      'Last Name: ${featureCompare.lastNameMatch}%'),
                  _buildListTile(Icons.male_rounded,
                      'Gender: ${featureCompare.genderMatch}%'),
                  _buildListTile(Icons.color_lens,
                      'Skin Color: ${featureCompare.skinColorMatch}%'),
                  _buildListTile(Icons.location_on,
                      'Last Seen Location: ${featureCompare.lastSeenLocationMatch}%'),
                  _buildListTile(Icons.health_and_safety,
                      'Medical Information: ${featureCompare.medicalInformationMatch}%'),
                  _buildListTile(Icons.report,
                      'Circumstance of Disappearance: ${featureCompare.circumstanceOfDisappearanceMatch}%'),
                  _buildListTile(Icons.report,
                      'Similarity Score: ${featureCompare.similarityScore}%'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Aggregate Similarity: ${featureCompare.aggregateSimilarity}%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Adjust the size as needed
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComparedMatchedDetails(
                                userId: userId, lastTime: lastTimeSeen),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // background (button) color
                        foregroundColor:
                            Colors.white, // foreground (text) color
                      ),
                      child: Text('View Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile(IconData icon, String text,
      {Color textColor = Colors.black}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
      ),
      title: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
 */
import 'package:missingpersonapp/features/compare/model/compare-model.dart';
import 'package:missingpersonapp/features/compare/screens/detail-matched.dart';
import 'package:flutter/material.dart';

class CompareMatchedPersonCard extends StatefulWidget {
  final List<FeatureCompare> featureCompareList;
  final int? lastTimeSeen;

  CompareMatchedPersonCard({super.key, required this.featureCompareList, this.lastTimeSeen});

  @override
  _CompareMatchedPersonCardState createState() => _CompareMatchedPersonCardState();
}

class _CompareMatchedPersonCardState extends State<CompareMatchedPersonCard> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Persons'),
      ),
      body: ListView.builder(
        itemCount: widget.featureCompareList.length,
        itemBuilder: (context, index) {
          final featureCompare = widget.featureCompareList[index];
          final userId = featureCompare.id;

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 5,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildListTile(Icons.person, 'First Name: ${featureCompare.firstNameMatch}%'),
                  _buildListTile(Icons.person, 'Middle Name: ${featureCompare.middleNameMatch}%'),
                  _buildListTile(Icons.person, 'Last Name: ${featureCompare.lastNameMatch}%'),
                  _buildListTile(Icons.male_rounded, 'Gender: ${featureCompare.genderMatch}%'),
                  if (showAll) ...[
                    _buildListTile(Icons.color_lens, 'Skin Color: ${featureCompare.skinColorMatch}%'),
                    _buildListTile(Icons.location_on, 'Last Seen Location: ${featureCompare.lastSeenLocationMatch}%'),
                    _buildListTile(Icons.health_and_safety, 'Medical Information: ${featureCompare.medicalInformationMatch}%'),
                    _buildListTile(Icons.report, 'Circumstance of Disappearance: ${featureCompare.circumstanceOfDisappearanceMatch}%'),
                    _buildListTile(Icons.report, 'Similarity Score: ${featureCompare.similarityScore}%'),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Aggregate Similarity: ${featureCompare.aggregateSimilarity}%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Adjust the size as needed
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!showAll)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAll = true;
                          });
                        },
                        child: Text('Show More'),
                      ),
                    ),
                  if (showAll)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAll = false;
                          });
                        },
                        child: Text('Show Less'),
                      ),
                    ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComparedMatchedDetails(userId: userId, lastTime: widget.lastTimeSeen),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // background (button) color
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 60.0, vertical: 15.0), // Button size
                      textStyle:
                          TextStyle(fontSize: 18), // foreground (text) color
                    ),
                      child: Text('View Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile(IconData icon, String text, {Color textColor = Colors.black}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
      ),
      title: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
