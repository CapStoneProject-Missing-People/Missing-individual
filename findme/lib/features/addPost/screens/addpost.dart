import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MissingPersonAddPage extends StatefulWidget {
  const MissingPersonAddPage({Key? key}) : super(key: key);

  @override
  _MissingPersonAddPageState createState() => _MissingPersonAddPageState();
}

class _MissingPersonAddPageState extends State<MissingPersonAddPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _lastPlaceSeenController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _skinColorController = TextEditingController();
  final TextEditingController _clothColorController = TextEditingController();
  final TextEditingController _bodySizeController = TextEditingController();
  final TextEditingController _uniqueFeatureController =
      TextEditingController();
  final TextEditingController _eyeColorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lastTimeSeenController = TextEditingController();

  String _selectedGender = 'Male'; // Default gender
  List<File> _images = []; // Variable to hold the image files
  bool _showClothColor =
      true; // Variable to control the visibility of Cloth Color field

  @override
  void initState() {
    super.initState();
    _lastTimeSeenController.addListener(_checkLastTimeSeen);
  }

  void _checkLastTimeSeen() {
    setState(() {
      final months = int.tryParse(_lastTimeSeenController.text) ?? 0;
      _showClothColor = months <= 2 || _lastTimeSeenController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _lastTimeSeenController.removeListener(_checkLastTimeSeen);
    _fullNameController.dispose();
    _lastPlaceSeenController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _skinColorController.dispose();
    _clothColorController.dispose();
    _bodySizeController.dispose();
    _uniqueFeatureController.dispose();
    _eyeColorController.dispose();
    _descriptionController.dispose();
    _lastTimeSeenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Missing Person'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _lastPlaceSeenController,
              decoration: const InputDecoration(
                  labelText: 'Last Place Seen',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _lastTimeSeenController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Last Time Seen (in months)',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gender:'),
                DropdownButton<String>(
                  value: _selectedGender,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    }
                  },
                  items: <String>['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Age', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                  labelText: 'Height', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _skinColorController,
              decoration: const InputDecoration(
                  labelText: 'Skin Color',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            if (_showClothColor) // Conditionally render the Cloth Color field
              TextFormField(
                controller: _clothColorController,
                decoration: const InputDecoration(
                    labelText: 'Cloth Color',
                    filled: true,
                    fillColor: Colors.white),
              ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bodySizeController,
              decoration: const InputDecoration(
                  labelText: 'Body Size',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _uniqueFeatureController,
              decoration: const InputDecoration(
                  labelText: 'Unique Feature',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _eyeColorController,
              decoration: const InputDecoration(
                  labelText: 'Eye Color',
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.white),
              maxLines: null, // Allow unlimited lines
            ),
            const SizedBox(height: 20),
            _buildUploadImageWidget(), // Upload image widget
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add submission functionality
              },
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 40), // Adjust button size
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadImageWidget() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Upload Image',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              List<XFile> pickedImages = await pickImages();
              setState(() {
                // Filter out already added images
                List<File> newImages = pickedImages
                    .map((e) => File(e.path))
                    .where((newImage) => !_images.any(
                        (existingImage) => newImage.path == existingImage.path))
                    .toList();
                _images.addAll(newImages);
              });
            },
            child: const Text('Choose Image'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _images
                .asMap()
                .entries
                .map(
                  (entry) => GestureDetector(
                    onTap: () {
                      _showImageDialog(entry.value, () {
                        // Remove image from list when tapped on dialog close
                        setState(() {
                          _images.removeAt(entry.key);
                        });
                      });
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.file(
                            entry.value,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () {
                              // Remove image from list when tapped on close icon
                              setState(() {
                                _images.removeAt(entry.key);
                              });
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(File image, Function onClose) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(
                  image,
                  fit: BoxFit.cover,
                  width: 500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    return images ?? [];
  }
}

void main() {
  runApp(
    MaterialApp(
      home: MissingPersonAddPage(),
    ),
  );
}
