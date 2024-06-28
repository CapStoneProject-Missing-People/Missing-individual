import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/screens/missing_person_detail1.dart';
import 'package:missingpersonapp/features/matchedCase/models/description_match_model.dart';
import 'package:missingpersonapp/features/matchedCase/provider/desc_match_provider.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/new_case_screen.dart';
import 'package:provider/provider.dart';

class ExistingCasesScreen extends StatefulWidget {
  const ExistingCasesScreen({super.key});

  @override
  State<ExistingCasesScreen> createState() => _ExistingCasesScreenState();
}

class _ExistingCasesScreenState extends State<ExistingCasesScreen> {
  @override
  void initState() {
    super.initState();
    final matchProvider =
        Provider.of<DescriptionMatchProvider>(context, listen: false);
    matchProvider.fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<DescriptionMatchProvider>(context);
    print('Matches in build method: ${matchProvider.matches}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Existing Cases'),
      ),
      body: matchProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : matchProvider.matches.isEmpty
              ? Center(child: Text('No matches found.'))
              : ListView.builder(
                  itemCount: matchProvider.matches.length,
                  itemBuilder: (context, index) {
                    final match = matchProvider.matches[index];
                    final existingCase = match.existingCaseDetails;

                    if (existingCase != null) {
                      return ExistingCaseListTile(
                        caseDetails: existingCase,
                        matchingStatus: match.matchingStatus,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewCaseDetailsScreen(
                                newCaseDetails: match.newCaseDetails!,
                                matchingStatus: match.matchingStatus,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
    );
  }
}

class ExistingCaseListTile extends StatelessWidget {
  final CaseDetails caseDetails;
  final MatchingStatus matchingStatus;
  final VoidCallback onTap;

  const ExistingCaseListTile({
    required this.caseDetails,
    required this.matchingStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                caseDetails.missingCaseId.imageBuffers.isNotEmpty
                  ? CarouselSlider(
                    items: caseDetails.missingCaseId.imageBuffers.map((buffer) {
                    return Image.memory(buffer, fit: BoxFit.cover, width: double.infinity);
                    }).toList(),
                    options: CarouselOptions(
                    height: 200,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: false,
                    ),
                  )
                  : SizedBox(),
              SizedBox(height: 10),
              Text(
                '${caseDetails.firstName} ${caseDetails.middleName} ${caseDetails.lastName}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${caseDetails.age}'),
                  Text('id: ${caseDetails.missingCaseId.id}'),
                  Text('Skin Color: ${caseDetails.skinColor}'),
                  Text(
                    'Similarity: ${matchingStatus.aggregateSimilarity}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: matchingStatus.aggregateSimilarity > 80 ? Colors.green : Colors.red,
                    ),
                  )
                ],
              )
              
            ],
          ),
        ),
      ),
    );
  }
}

