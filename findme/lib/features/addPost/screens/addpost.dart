import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:findme/features/addPost/models/addpost_model.dart';

class MissingPersonAddPage extends StatefulWidget {
  const MissingPersonAddPage({Key? key}) : super(key: key);

  @override
  _MissingPersonAddPageState createState() => _MissingPersonAddPageState();
}

class _MissingPersonAddPageState extends State<MissingPersonAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _lastPlaceSeenController =
      TextEditingController();
  final TextEditingController _lastTimeSeenController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _eyeDescriptionController =
      TextEditingController();
  final TextEditingController _noseDescriptionController =
      TextEditingController();
  final TextEditingController _hairDescriptionController =
      TextEditingController();

  String _selectedGender = 'Male';
  String _selectedSkinColor = 'fair';
  String _selectedBodySize = 'thin';
  String _selectedUpperClothType = 'tshirt';
  String _selectedUpperClothColor = 'red';
  String _selectedLowerClothType = 'trouser';
  String _selectedLowerClothColor = 'blue';

  List<File> _images = [];
  bool _showClothDetails = true;

  @override
  void initState() {
    super.initState();
    _lastTimeSeenController.addListener(_checkLastTimeSeen);
  }

  void _checkLastTimeSeen() {
    setState(() {
      final months = int.tryParse(_lastTimeSeenController.text) ?? 0;
      _showClothDetails = months <= 2 || _lastTimeSeenController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _lastTimeSeenController.removeListener(_checkLastTimeSeen);
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _lastPlaceSeenController.dispose();
    _lastTimeSeenController.dispose();
    _ageController.dispose();
    _eyeDescriptionController.dispose();
    _noseDescriptionController.dispose();
    _hairDescriptionController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final missingPerson = MissingPerson(
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
        lastPlaceSeen: _lastPlaceSeenController.text,
        lastTimeSeen: int.parse(_lastTimeSeenController.text),
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        skinColor: _selectedSkinColor,
        upperClothType: _selectedUpperClothType,
        upperClothColor: _selectedUpperClothColor,
        lowerClothType: _selectedLowerClothType,
        lowerClothColor: _selectedLowerClothColor,
        bodySize: _selectedBodySize,
        eyeDescription: _eyeDescriptionController.text,
        noseDescription: _noseDescriptionController.text,
        hairDescription: _hairDescriptionController.text,
        imagePaths: _images.map((file) => file.path).toList(),
      );

      postData(missingPerson);
    }
  }

  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    return images ?? [];
  }

  void postData(MissingPerson missingPerson) async {
    final url = Uri.parse(
        '192.168.219.140/api/features/create/:timeSinceDisappearance');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(missingPerson.toJson()),
      );

      if (response.statusCode == 200) {
        // Handle success
        print('Data submitted successfully');
        Navigator.pop(context);
      } else {
        // Handle error
        print('Failed to submit data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Missing Person'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                    labelText: 'First Name',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'First name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                    labelText: 'Middle Name',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Middle name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                    labelText: 'Last Name',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Last name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastPlaceSeenController,
                decoration: const InputDecoration(
                    labelText: 'Last Place Seen',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Last place seen is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastTimeSeenController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Last Time Seen (in months)',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Last time seen is required'
                    : null,
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
                    items: <String>['Male', 'Female']
                        .map<DropdownMenuItem<String>>((String value) {
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
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Age is required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Skin Color:'),
                  DropdownButton<String>(
                    value: _selectedSkinColor,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedSkinColor = newValue;
                        });
                      }
                    },
                    items: <String>['fair', 'black', 'white', 'tseyim']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Body Size:'),
                  DropdownButton<String>(
                    value: _selectedBodySize,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedBodySize = newValue;
                        });
                      }
                    },
                    items: <String>[
                      'thin',
                      'average',
                      'muscular',
                      'overweight',
                      'obese',
                      'fit',
                      'athletic',
                      'curvy',
                      'petite',
                      'fat'
                    ].map<DropdownMenuItem<String>>((String value) {
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
                controller: _eyeDescriptionController,
                decoration: const InputDecoration(
                    labelText: 'Eye Description',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Eye description is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noseDescriptionController,
                decoration: const InputDecoration(
                    labelText: 'Nose Description',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Nose description is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _hairDescriptionController,
                decoration: const InputDecoration(
                    labelText: 'Hair Description',
                    filled: true,
                    fillColor: Colors.white),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Hair description is required'
                    : null,
              ),
              const SizedBox(height: 10),
              if (_showClothDetails) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upper Cloth Type:'),
                    DropdownButton<String>(
                      value: _selectedUpperClothType,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedUpperClothType = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'tshirt',
                        'hoodie',
                        'sweater',
                        'sweetshirt'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upper Cloth Color:'),
                    DropdownButton<String>(
                      value: _selectedUpperClothColor,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedUpperClothColor = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'red',
                        'blue',
                        'white',
                        'black',
                        'orange',
                        'light blue',
                        'brown',
                        'blue black',
                        'yellow'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lower Cloth Type:'),
                    DropdownButton<String>(
                      value: _selectedLowerClothType,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLowerClothType = newValue;
                          });
                        }
                      },
                      items: <String>['trouser', 'shorts', 'nothing', 'boxer']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lower Cloth Color:'),
                    DropdownButton<String>(
                      value: _selectedLowerClothColor,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLowerClothColor = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'blue',
                        'black',
                        'white',
                        'red',
                        'orange',
                        'light blue',
                        'brown',
                        'blue black',
                        'yellow'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final pickedImages = await pickImages();
                  setState(() {
                    _images.addAll(
                        pickedImages.map((image) => File(image.path)).toList());
                  });
                },
                child: const Text('Pick Images'),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _images.map((image) {
                  return Image.file(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MissingPersonAddPage(),
  ));
}
