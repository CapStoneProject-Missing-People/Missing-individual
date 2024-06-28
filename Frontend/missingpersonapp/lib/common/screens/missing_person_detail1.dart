import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/common/utils/add_guard.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/chat/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart'; // New import for phone call

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
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (isChatVisible) {
          setState(() {
            isChatVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!isChatVisible) {
          setState(() {
            isChatVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

 // Function to convert ISO 8601 date to a more readable format
  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    return formattedDate;
  }
  GestureDetector buildContainer(
      String text1, String text2, IconData text3, BuildContext context) {
    return GestureDetector(
      onTap: text3 == Icons.phone
          ? () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: text2);
              if (await canLaunch(phoneUri.toString())) {
                await launch(phoneUri.toString());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch $text2')),
                );
              }
            }
          : null,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15),
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
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16)),
                  Text(
                    text2,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
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
                  CarouselSlider.builder(
                    itemCount: widget.missingPerson.photos.length,
                    itemBuilder: (context, index, realIndex) {
                      final imageBytes = widget.missingPerson.photos[index];
                      return buildImage(imageBytes, index);
                    },
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
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
                  buildContainer('First Name', '${widget.missingPerson.name}',
                      Icons.person, context),
                  buildContainer('Middle name', '${widget.missingPerson.middleName}',
                      Icons.person, context),
                  buildContainer('Last name', '${widget.missingPerson.lastName}',
                      Icons.person, context),
                  buildContainer('Gender', '${widget.missingPerson.gender}',
                      Icons.calendar_month, context),
                  buildContainer('Age', '${widget.missingPerson.age}',
                      Icons.calendar_month, context),
                  buildContainer('Status', '${widget.missingPerson.status}',
                      Icons.calendar_month, context),
                  buildContainer('Skin Color', '${widget.missingPerson.skin_color}',
                      Icons.color_lens_outlined, context),
                  buildContainer('Description',
                      '${widget.missingPerson.description}', Icons.book, context),
                  buildContainer('Time Since Disappearance', '${widget.missingPerson.timeSinceDisappearance} months',
                      Icons.timelapse, context),
                  buildContainer('Date Reported', '${widget.missingPerson.dateReported}',
                      Icons.date_range, context),
                  buildContainer('Last Seen Location', '${widget.missingPerson.lastSeenLocation}',
                      Icons.location_city, context),
                  buildContainer('medical Information', '${widget.missingPerson.medicalInformation}',
                      Icons.medical_information, context),
                  buildContainer('Circumstance of Disappearance', '${widget.missingPerson.circumstanceOfDisappearance}',
                      Icons.dashboard, context),
                  buildContainer('Contact using this Phone', '${widget.missingPerson.posterPhone}',
                      Icons.phone, context),
                  buildContainer('Contact using this email', '${widget.missingPerson.posterEmail}',
                      Icons.email, context),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isChatVisible && currentUser.id != widget.missingPerson.id,
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
                          builder: (context) => AuthGuard(child: ChatScreen(
                            receiverId: widget.missingPerson.poster_id,
                          ),)
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
