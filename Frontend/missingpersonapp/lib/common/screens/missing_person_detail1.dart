import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:typed_data';

class MissingPersonDetails extends StatefulWidget {
  final MissingPerson missingPerson;
  final String header;

  const MissingPersonDetails(
      {Key? key, required this.missingPerson, required this.header})
      : super(key: key);

  @override
  State<MissingPersonDetails> createState() => _MissingPersonDetailsState();
}

class _MissingPersonDetailsState extends State<MissingPersonDetails> {
  int activeIndex = 0;

  Container buildContainer(
      String text1, String text2, IconData text3, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
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
            padding: const EdgeInsets.all(10),
            child: Icon(text3, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text1,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                Text(text2,
                    textAlign: TextAlign.start,
                    style:
                        const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(widget.header),
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
                  return buildImage(imageBytes, index);
                },
                options: CarouselOptions(
                  height: 350,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) =>
                      setState(() => activeIndex = index),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: widget.missingPerson.photos.length > 1
                    ? buildIndicator(activeIndex, widget.missingPerson.photos)
                    : Container(),
              ),
              const SizedBox(height: 20),
              buildContainer('Name', '${widget.missingPerson.name}',
                  Icons.person, context),
              const SizedBox(height: 5),
              buildContainer('Age', '${widget.missingPerson.age}',
                  Icons.calendar_month, context),
              const SizedBox(height: 5),
              buildContainer('Skin Color', '${widget.missingPerson.skin_color}',
                  Icons.color_lens_outlined, context),
              const SizedBox(height: 5),
              buildContainer('Phone Number', '${widget.missingPerson.phoneNo}',
                  Icons.phone, context),
              const SizedBox(height: 5),
              buildContainer('Description',
                  '${widget.missingPerson.description}', Icons.book, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int activeIndex, List<Uint8List> images) =>
      AnimatedSmoothIndicator(
        effect: const ExpandingDotsEffect(dotWidth: 10, activeDotColor: Colors.blue),
        activeIndex: activeIndex,
        count: images.length,
      );

  Widget buildImage(Uint8List imageBytes, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      ),
    );
  }
}
