import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../features/chat/screens/chat_screen.dart';

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
  bool isChatVisible = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward ||
          _scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          isChatVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Container buildContainer(
      String label, String value, IconData icon, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
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
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[400],
            ),
            padding: EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                Text(value,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.missingPerson.photos.isNotEmpty)
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
                  SizedBox(height: 12),
                  if (widget.missingPerson.photos.length > 1)
                    Center(
                      child: buildIndicator(activeIndex, widget.missingPerson.photos),
                    ),
                  SizedBox(height: 20),
                  buildContainer('First Name', widget.missingPerson.name.firstName, Icons.person, context),
                  buildContainer('Middle Name', widget.missingPerson.name.middleName, Icons.person, context),
                  buildContainer('Last Name', widget.missingPerson.name.lastName, Icons.person, context),
                  buildContainer('Age', widget.missingPerson.age.toString(), Icons.calendar_month, context),
                  buildContainer('Gender', widget.missingPerson.gender, Icons.person_outline, context),
                  buildContainer('Skin Color', widget.missingPerson.skinColor, Icons.color_lens_outlined, context),
                  buildContainer('Body Size', widget.missingPerson.bodySize ?? '', Icons.straighten, context), // Default value
                  buildContainer('Phone Number', '123-456-7890', Icons.phone, context), // Placeholder
                  buildContainer('Description', widget.missingPerson.description, Icons.book, context),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isChatVisible,
            child: Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        isChatVisible = false;
                      });
                    },
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: widget.missingPerson.userId, // Placeholder
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.chat),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator(int activeIndex, List<Uint8List> images) =>
      AnimatedSmoothIndicator(
        effect: ExpandingDotsEffect(dotWidth: 10, activeDotColor: Colors.blue),
        activeIndex: activeIndex,
        count: images.length,
      );

  Widget buildImage(Uint8List imageBytes, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      ),
    );
  }
}
