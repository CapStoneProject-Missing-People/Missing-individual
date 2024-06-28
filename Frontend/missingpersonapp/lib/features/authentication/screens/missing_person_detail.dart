
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/authentication/models/missing_person_model.dart';
import 'package:missingpersonapp/features/authentication/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';

class MissingPersonDetails extends StatefulWidget {
  final MissingPersonSpecific missingPerson;

  const MissingPersonDetails({super.key, required this.missingPerson});

  @override
  State<MissingPersonDetails> createState() => _MissingPersonDetailsState();
}

class _MissingPersonDetailsState extends State<MissingPersonDetails> {
  int activeIndex = 0;
  List<Uint8List> photos = [];

  @override
  void initState() {
    super.initState();
    photos = List.from(widget.missingPerson.photos);
  }

  Future<void> editField(
      BuildContext context, String field, String currentValue) async {
    String newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text("Edit $field", style: TextStyle(color: Colors.white)),
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
            child: Text("Save", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop(newValue);
            },
          ),
        ],
      ),
    );

    if (newValue != currentValue) {
      try {
        Provider.of<MissingPersonProvider>(context, listen: false)
            .updateMissingPersonField(
          widget.missingPerson,
          field,
          newValue,
          context
        );
      } catch (error) {
        // Handle the error appropriately
        print('Error updating missing person field: $error');
        // Show a user-friendly message using a SnackBar, AlertDialog, etc.
        showToast(context, error.toString(), Colors.red);
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        photos.add(bytes);
      });
    }
  }

  Future<void> submitImages() async {
    try {
      Provider.of<MissingPersonProvider>(context, listen: false)
          .updateMissingPersonPhotos(
        widget.missingPerson,
        photos,
        context
      );
      showToast(context, 'Images updated successfully!', Colors.green);
    } catch (error) {
      print('Error updating images: $error');
      showToast(context, error.toString(), Colors.red);
    }
  }

  Container buildContainer(
      String field, String value, IconData icon, BuildContext context) {
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
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(width: 10), // Adjust the space between the icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field,
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                Text(value,
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              ],
            ),
          ),
          Container(
            child: IconButton(
              onPressed: () => editField(context, field, value),
              icon: Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missingPerson = widget.missingPerson;
    final user = Provider.of<UserProvider>(context).user;

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
                itemCount: photos.length + 1,
                itemBuilder: (context, index, realIndex) {
                  if (index < photos.length) {
                    final imageBytes = photos[index];
                    return Stack(
                      children: [
                        buildImage(imageBytes, index),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() {
                              photos.removeAt(index);
                            }),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_a_photo,
                              size: 50, color: Colors.blue),
                          onPressed: pickImage,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to add a new photo',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: submitImages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // background color
                            foregroundColor:
                                Colors.white, // text (foreground) color
                          ),
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  }
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
                child: photos.length > 1
                    ? buildIndicator(activeIndex, photos)
                    : Container(), // Return an empty container if condition is false
              ),
              SizedBox(height: 20),
              buildContainer('First Name', missingPerson.name.firstName,
                  Icons.person, context),
              SizedBox(height: 5),
              buildContainer('Last Name', missingPerson.name.lastName,
                  Icons.person, context),
              SizedBox(height: 5),
              buildContainer('Age', missingPerson.age.toString(),
                  Icons.calendar_month, context),
              SizedBox(height: 5),
              buildContainer(
                  'Gender', missingPerson.gender, Icons.location_city, context),
              SizedBox(height: 5),
              buildContainer(
                  'Phone Number', user.phoneNo, Icons.location_city, context),
              SizedBox(height: 5),
              buildContainer('Skin Color', missingPerson.skin_color,
                  Icons.location_city, context),
              SizedBox(height: 5),
              buildContainer(
                  'Body Size', missingPerson.body_size, Icons.phone, context),
              SizedBox(height: 5),
              buildContainer(
                  'Upper Cloth Type',
                  missingPerson.clothing.upper.clothType,
                  Icons.location_city,
                  context),
              SizedBox(height: 5),
              buildContainer(
                  'Upper Cloth Color',
                  missingPerson.clothing.upper.clothColor,
                  Icons.location_city,
                  context),
              SizedBox(height: 5),
              buildContainer(
                  'Lower Cloth Type',
                  missingPerson.clothing.lower.clothType,
                  Icons.location_city,
                  context),
              SizedBox(height: 5),
              buildContainer(
                  'Lower Cloth Color',
                  missingPerson.clothing.lower.clothColor,
                  Icons.location_city,
                  context),
              SizedBox(height: 5),
              buildContainer('Description', missingPerson.description,
                  Icons.book, context),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: submitImages,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int active, List<Uint8List> images) =>
      AnimatedSmoothIndicator(
        effect: ExpandingDotsEffect(dotWidth: 10, activeDotColor: Colors.blue),
        activeIndex: active,
        count: images.length,
      );

  /* Widget buildImage(Uint8List imageBytes, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      ),
    );
  } */
  Widget buildImage(Uint8List imageBytes, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: double.infinity, // Ensure container takes full width
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover, // Ensures image covers the container
          width: double.infinity, // Ensures image takes full width
          height: 350, // Set a fixed height for consistency
        ),
      ),
    );
  }
}
