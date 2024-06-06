import 'dart:typed_data';
import 'package:missingpersonapp/features/compare/data/fetchCompare.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:missingpersonapp/features/compare/model/matched-compare.dart';

class ComparedMatchedDetails extends StatefulWidget {
  final String userId;

  const ComparedMatchedDetails({super.key, required this.userId});

  @override
  State<ComparedMatchedDetails> createState() => _MissingPersonDetailsState();
}

class _MissingPersonDetailsState extends State<ComparedMatchedDetails> {
  int activeIndex = 0;
  bool isLoading = true;
  List<MatchedPersonAddCompare> matchedPeople = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMatchedData();
  }

  Future<void> fetchMatchedData() async {
    try {
      final data = await fetchMatchedPeople(widget.userId);
      setState(() {
        matchedPeople = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<void> editField(BuildContext context, field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[800],
              title:
                  Text("Edit " + field, style: TextStyle(color: Colors.white)),
              content: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                TextButton(
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(newValue))
              ],
            ));
  }

  Container buildContainer(
      String text1, String text2, IconData text3, BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[400],
                ),
                padding: EdgeInsets.all(10),
                child: Icon(text3, color: Colors.white)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text1,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  Text(text2,
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                ],
              ),
            ),
            Container(
                child: IconButton(
                    onPressed: () => editField(context, text1),
                    icon: Icon(Icons.edit)))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text('Matched Person Details'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text('Error: $errorMessage'))
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: matchedPeople.isEmpty
                            ? [Text('No matched people found.')]
                            : matchedPeople.map((person) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CarouselSlider.builder(
                                        itemCount: person.photos.length,
                                        itemBuilder:
                                            (context, index, realIndex) {
                                          final urlImage = person.photos[index];
                                          return buildImage(urlImage, index);
                                        },
                                        options: CarouselOptions(
                                          height: 350,
                                          enableInfiniteScroll: false,
                                          onPageChanged: (index, reason) =>
                                              setState(
                                                  () => activeIndex = index),
                                        )),
                                    SizedBox(height: 12),
                                    Center(
                                      child: person.photos.length > 1
                                          ? buildIndicator(
                                              activeIndex, person.photos)
                                          : Container(),
                                    ),
                                    const SizedBox(height: 20),
                                    buildContainer(
                                        'First Name',
                                        '${person.firstName}',
                                        Icons.person,
                                        context),
                                    SizedBox(height: 5),
                                    buildContainer(
                                        'Middle Name',
                                        '${person.middleName}',
                                        Icons.person,
                                        context),
                                    SizedBox(height: 5),
                                    buildContainer(
                                        'Last Name',
                                        '${person.lastName}',
                                        Icons.person,
                                        context),
                                    SizedBox(height: 5),
                                    buildContainer('Age', '${person.age}',
                                        Icons.calendar_month, context),
                                    SizedBox(height: 5),
                                    buildContainer(
                                        'Last Seen Place',
                                        '${person.lastSeenPlace}',
                                        Icons.location_city,
                                        context),
                                    SizedBox(height: 5),
                                    buildContainer(
                                        'Phone Number',
                                        '${person.phoneNumber}',
                                        Icons.phone,
                                        context),
                                    SizedBox(height: 5),
                                    buildContainer(
                                        'Skin Color',
                                        '${person.skinColor}',
                                        Icons.book,
                                        context),
                                    SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
                      ),
                    ),
                  ));
  }
}

Widget buildIndicator(active, images) => AnimatedSmoothIndicator(
      effect: ExpandingDotsEffect(dotWidth: 10, activeDotColor: Colors.blue),
      activeIndex: active,
      count: images.length,
    );

Widget buildImage(Uint8List urlImage, int index) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.memory(
        urlImage,
        fit: BoxFit.cover,
      ));
}
