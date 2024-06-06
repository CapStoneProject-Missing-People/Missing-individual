import 'package:carousel_slider/carousel_slider.dart';
import 'package:findme/features/matchedCase/models/matched-person-model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MissingPersonDetails extends StatefulWidget {
  final MissingPersonAdd missingPerson;

  const MissingPersonDetails({super.key, required this.missingPerson});

  @override
  State<MissingPersonDetails> createState() => _MissingPersonDetailsState();
}

class _MissingPersonDetailsState extends State<MissingPersonDetails> {
  int activeIndex = 0;

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
              offset: Offset(0, 3), // changes position of shadow
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
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text('Missing Person Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider.builder(
                  itemCount: widget.missingPerson.photos.length,
                  itemBuilder: (context, index, realIndex) {
                    final imageBytes = widget.missingPerson.photos[index];
                    return buildImage(imageBytes as String, index);
                  },
                  options: CarouselOptions(
                    height: 350,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) =>
                        setState(() => activeIndex = index),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: widget.missingPerson.photos.length > 1
                      ? buildIndicator(activeIndex, widget.missingPerson.photos)
                      : Container(),
                ),
                const SizedBox(height: 20),
                buildContainer('Name', '${widget.missingPerson.firstName}',
                    Icons.person, context),
                SizedBox(height: 5),
                buildContainer('Age', '${widget.missingPerson.age}',
                    Icons.calendar_month, context),
                SizedBox(height: 5),
                buildContainer(
                    "Last Seen Place",
                    '${widget.missingPerson.lastSeenPlace}',
                    Icons.location_city,
                    context),
                SizedBox(height: 5),
                buildContainer(
                    "Phone Number",
                    '${widget.missingPerson.phoneNumber}',
                    Icons.phone,
                    context),
              ],
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

Widget buildImage(String urlImage, int index) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.network(
        urlImage,
        fit: BoxFit.cover,
      ));
}
