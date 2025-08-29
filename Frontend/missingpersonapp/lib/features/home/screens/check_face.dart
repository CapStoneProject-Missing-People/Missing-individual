import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/features/home/provider/check_face_provider.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/home/screens/match_detail.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';

class CheckFace extends StatelessWidget {
  final String imagePath;

  const CheckFace({super.key, required this.imagePath});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: source);
    if (image != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckFace(imagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckFaceProvider(),
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.grey.shade800],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Consumer<CheckFaceProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 40),
                            // Header
                            const Text(
                              "Face Recognition",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Check for potential matches",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Image Preview with Glassmorphism
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.file(
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                      width: 250,
                                      height: 250,
                                    ),
                                    if (provider.loading)
                                      Container(
                                        width: 250,
                                        height: 250,
                                        color: Colors.black.withOpacity(0.5),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Search Buttons Section
                            if (provider.apiResult == null)
                              GlassmorphismButton(
                                onPressed: () async {
                                  provider.setLoading(true);
                                  final String? result =
                                      await provider.sendImageToAPI(imagePath);
                                  provider.setLoading(false);
                                  if (result != null) {
                                    provider.handleApiResponse(result);
                                  }
                                },
                                child: provider.loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.search,
                                              color: Colors.white),
                                          SizedBox(width: 10),
                                          Text(
                                            'Search for Matches',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                            // Results Section
                            if (provider.apiResult != null)
                              AnimatedOpacity(
                                opacity: provider.apiResult != null ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Match Result Text
                                      Text(
                                        provider.apiResult!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),

                                      // View Details Button if match found
                                      if (provider.personId != null)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PersonDetailsScreen(
                                                        personId:
                                                            provider.personId!),
                                              ),
                                            );
                                          },
                                          onHorizontalDragEnd: (details) {
                                            if (details.primaryVelocity !=
                                                    null &&
                                                details.primaryVelocity! > 0) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PersonDetailsScreen(
                                                          personId: provider
                                                              .personId!),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.person_outline,
                                                  color: Colors.white),
                                              SizedBox(width: 10),
                                              Text(
                                                'View Person Details',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ),

                                      // Search Again Options
                                      const SizedBox(height: 30),
                                      const Text(
                                        'Search Options:',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Search Again with Same Image
                                      OutlinedButton(
                                        onPressed: () async {
                                          provider.setLoading(true);
                                          final String? result = await provider
                                              .sendImageToAPI(imagePath);
                                          provider.setLoading(false);
                                          if (result != null) {
                                            provider.handleApiResponse(result);
                                          }
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.refresh,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'Search Again',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),

                                      // Use Different Image
                                      OutlinedButton(
                                        onPressed: () =>
                                            _showImageSourceDialog(context),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.image_outlined,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              'Use Different Image',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Additional Info Section if match found
                                      if (provider.personId != null) ...[
                                        const SizedBox(height: 30),
                                        const Text(
                                          'Help us improve the match:',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Location Sharing
                                        GestureDetector(
                                          onTap: () =>
                                              provider.shareLocation(context),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color:
                                                  provider.shareLocationValue !=
                                                          null
                                                      ? Colors.green
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color:
                                                    provider.shareLocationValue !=
                                                            null
                                                        ? Colors.green
                                                        : Colors.white
                                                            .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color:
                                                          provider.shareLocationValue !=
                                                                  null
                                                              ? Colors.green
                                                              : Colors.white,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Text(
                                                      provider.shareLocationValue !=
                                                              null
                                                          ? 'Location Shared'
                                                          : 'Share Your Location',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (provider
                                                        .shareLocationValue !=
                                                    null)
                                                  const Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Contact Information
                                        TextField(
                                          controller:
                                              provider.contactController,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText:
                                                'Your Contact Information',
                                            labelStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7)),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.contact_phone_outlined,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Submit Button
                                        GlassmorphismButton(
                                          onPressed: () {
                                            provider.updateMatch(context);
                                          },
                                          child: const Text(
                                            'Submit Information',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Back Button
                Positioned(
                  top: 10,
                  left: 10,
                  child: GlassmorphismButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GlassmorphismButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Take Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                GlassmorphismButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Choose from Gallery',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
