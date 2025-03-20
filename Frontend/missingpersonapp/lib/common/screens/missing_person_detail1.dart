import 'dart:ui';

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
import 'package:url_launcher/url_launcher.dart'; // For phone call and email

class MissingPersonDetails extends StatefulWidget {
  final MissingPerson missingPerson;
  final String header;

  const MissingPersonDetails(
      {super.key, required this.missingPerson, required this.header});

  @override
  State<MissingPersonDetails> createState() => _MissingPersonDetailsState();
}

class _MissingPersonDetailsState extends State<MissingPersonDetails> {
  int activeIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to format date
  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  // Build a modern detail row
  Widget buildDetailRow(String title, String value, IconData icon, {bool fullWidth = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    final screenHeight = MediaQuery.of(context).size.height;

    // Number of details to show per slide based on screen height
    final detailsPerSlide = screenHeight < 600 ? 3 : 4;

    // Group details into chunks for each slide
    final List<List<Widget>> detailSlides = [];
    final List<Widget> allDetails = [
      // Full-width row for name
      buildDetailRow(
        'Full Name',
        '${widget.missingPerson.name} ${widget.missingPerson.middleName} ${widget.missingPerson.lastName}',
        Icons.person_outline,
        fullWidth: true,
      ),
      // Half-width rows for other details
      Row(
        children: [
          Expanded(
            child: buildDetailRow('Gender', widget.missingPerson.gender,
                widget.missingPerson.gender.toLowerCase() == 'female'
                    ? Icons.female_outlined
                    : Icons.male_outlined),
          ),
          Expanded(
            child: buildDetailRow('Age', '${widget.missingPerson.age}', Icons.cake_outlined),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: buildDetailRow('Skin Color', widget.missingPerson.skin_color,
                Icons.palette_outlined),
          ),
          Expanded(
            child: buildDetailRow('Status', widget.missingPerson.status, Icons.info_outline),
          ),
        ],
      ),
      buildDetailRow(
        'Time Since Disappearance',
        '${widget.missingPerson.timeSinceDisappearance} months',
        Icons.timelapse_outlined,
        fullWidth: true,
      ),
      buildDetailRow(
        'Date Reported',
        formatDate(widget.missingPerson.dateReported),
        Icons.date_range_outlined,
        fullWidth: true,
      ),
      buildDetailRow(
        'Last Seen Location',
        widget.missingPerson.lastSeenLocation,
        Icons.location_on_outlined,
        fullWidth: true,
      ),
      buildDetailRow(
        'Medical Information',
        widget.missingPerson.medicalInformation,
        Icons.medical_services_outlined,
        fullWidth: true,
      ),
      buildDetailRow(
        'Circumstance of Disappearance',
        widget.missingPerson.circumstanceOfDisappearance,
        Icons.help_outline,
        fullWidth: true,
      ),
    ];

    for (var i = 0; i < allDetails.length; i += detailsPerSlide) {
      detailSlides.add(allDetails.sublist(
          i, i + detailsPerSlide > allDetails.length ? allDetails.length : i + detailsPerSlide));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Carousel with overlay text
                Stack(
                  alignment: Alignment.bottomCenter,
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
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.missingPerson.name} ${widget.missingPerson.lastName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: widget.missingPerson.photos.length > 1
                      ? buildIndicator(activeIndex, widget.missingPerson.photos)
                      : Container(),
                ),
                const SizedBox(height: 20),
                // Swipeable details with visual cue at the top
                Expanded(
                  child: Column(
                    children: [
                      // Swipe indicator at the top
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Swipe for more details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                      // PageView for details with bottom padding
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 100), // Add padding to avoid overlap
                          child: PageView(
                            controller: _pageController,
                            children: detailSlides
                                .map((details) => ListView(
                                      children: details,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Floating action bar at the bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Contact Phone
                        GestureDetector(
                          onTap: () async {
                            final Uri phoneUri = Uri(scheme: 'tel', path: widget.missingPerson.posterPhone);
                            if (await canLaunch(phoneUri.toString())) {
                              await launch(phoneUri.toString());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not launch phone app')),
                              );
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_outlined, color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Contact Email
                        GestureDetector(
                          onTap: () async {
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: widget.missingPerson.posterEmail,
                            );
                            if (await canLaunch(emailUri.toString())) {
                              await launch(emailUri.toString());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not launch email app')),
                              );
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_outlined, color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Chat Button
                        if (currentUser.id != widget.missingPerson.id)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthGuard(
                                    child: ChatScreen(
                                      receiverId: widget.missingPerson.poster_id,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_outlined, color: Colors.white),
                                const SizedBox(height: 4),
                                Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // AppBar with back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 180, sigmaY: 80), // Blur effect
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.header,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int activeIndex, List<Uint8List> images) =>
      AnimatedSmoothIndicator(
        effect: const ExpandingDotsEffect(
            dotWidth: 10, activeDotColor: Colors.blue),
        activeIndex: activeIndex,
        count: images.length,
      );

  Widget buildImage(Uint8List imageBytes, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
