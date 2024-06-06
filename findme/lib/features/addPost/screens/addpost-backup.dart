import 'dart:io';
import 'package:findme/features/addPost/models/addpost_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MissingPersonAddPage extends StatefulWidget {
  const MissingPersonAddPage({super.key});

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
  final TextEditingController _lastAddressDescController =
      TextEditingController();
  final TextEditingController _medicalInformation = TextEditingController();
  final TextEditingController _circumstanceOfDisappearance =
      TextEditingController();
  final TextEditingController _eyeDescriptionController =
      TextEditingController();
  final TextEditingController _noseDescriptionController =
      TextEditingController();
  final TextEditingController _hairDescriptionController =
      TextEditingController();

  String _selectedGender = 'male';
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
    _lastAddressDescController.dispose();
    _medicalInformation.dispose();
    _circumstanceOfDisappearance.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final missingPerson = MissingPerson(
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
        lastSeenLocation: _lastPlaceSeenController.text,
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
        lastAddressDesc: _lastAddressDescController.text,
        medicalInformation: _medicalInformation.text,
        circumstanceOfDisappearance: _circumstanceOfDisappearance.text,
        imagePaths: _images.map((file) => file.path).toList(),
      );

      final success = await postData(missingPerson);
      if (success) {
        Fluttertoast.showToast(
          msg: "Data submitted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to submit data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<bool> postData(MissingPerson missingPerson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final url = Uri.parse(
        'http://192.168.188.100:4000/api/createMissingPerson/${missingPerson.lastTimeSeen}');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['firstName'] = missingPerson.firstName;
      request.fields['middleName'] = missingPerson.middleName;
      request.fields['lastName'] = missingPerson.lastName;
      request.fields['last_place_seen'] = missingPerson.lastSeenLocation;
      request.fields['last_time_seen'] = missingPerson.lastTimeSeen.toString();
      request.fields['gender'] = missingPerson.gender;
      request.fields['age'] = missingPerson.age.toString();
      request.fields['skin_color'] = missingPerson.skinColor;
      request.fields['clothingUpperClothType'] = missingPerson.upperClothType;
      request.fields['clothingUpperClothColor'] = missingPerson.upperClothColor;
      request.fields['clothingLowerClothType'] = missingPerson.lowerClothType;
      request.fields['clothingLowerClothColor'] = missingPerson.lowerClothColor;
      request.fields['body_size'] = missingPerson.bodySize;
      request.fields['eyeDescription'] = missingPerson.eyeDescription;
      request.fields['noseDescription'] = missingPerson.noseDescription;
      request.fields['hairDescription'] = missingPerson.hairDescription;
      request.fields['medicalInformation'] = missingPerson.medicalInformation;
      request.fields['circumstanceOfDisappearance'] =
          missingPerson.circumstanceOfDisappearance;
      request.fields['lastSeenAddressDes'] = missingPerson.lastAddressDesc;

      for (var i = 0; i < _images.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          _images[i].path,
        ));
      }

      print("PRINT THE REQUEST : ${request.files}");
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Network error: $e');
      return false;
    }
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
              _buildTextFormField(_firstNameController, 'First Name'),
              const SizedBox(height: 10),
              _buildTextFormField(_middleNameController, 'Middle Name'),
              const SizedBox(height: 10),
              _buildTextFormField(_lastNameController, 'Last Name'),
              const SizedBox(height: 10),
              _buildTextFormField(
                  _lastPlaceSeenController, 'Last Seen Location'),
              const SizedBox(height: 10),
              _buildTextFormField(_lastTimeSeenController,
                  'Last Time Seen (in months)', TextInputType.number),
              const SizedBox(height: 10),
              _buildDropdown('Gender:', _selectedGender, ['male', 'female'],
                  (newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              }),
              const SizedBox(height: 10),
              _buildTextFormField(_ageController, 'Age', TextInputType.number),
              const SizedBox(height: 10),
              _buildDropdown('Skin Color:', _selectedSkinColor,
                  ['fair', 'black', 'white', 'tseyim'], (newValue) {
                setState(() {
                  _selectedSkinColor = newValue!;
                });
              }),
              const SizedBox(height: 10),
              _buildDropdown('Body Size:', _selectedBodySize, [
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
              ], (newValue) {
                setState(() {
                  _selectedBodySize = newValue!;
                });
              }),
              const SizedBox(height: 10),
              _buildTextFormField(_eyeDescriptionController, 'Eye Description'),
              const SizedBox(height: 10),
              _buildTextFormField(
                  _noseDescriptionController, 'Nose Description'),
              const SizedBox(height: 10),
              _buildTextFormField(
                  _hairDescriptionController, 'Hair Description'),
              const SizedBox(height: 10),
              _buildTextFormField(_medicalInformation, 'Medical Information'),
              const SizedBox(height: 10),
              _buildTextFormField(
                  _circumstanceOfDisappearance, 'Circumstance Of Disapperance'),
              _buildTextFormField(
                  _lastAddressDescController, 'Last Seen Address Description'),
              const SizedBox(height: 10),
              if (_showClothDetails) ...[
                _buildDropdown('Upper Cloth Type:', _selectedUpperClothType,
                    ['tshirt', 'hoodie', 'sweater', 'sweetshirt'], (newValue) {
                  setState(() {
                    _selectedUpperClothType = newValue!;
                  });
                }),
                const SizedBox(height: 10),
                _buildDropdown('Upper Cloth Color:', _selectedUpperClothColor, [
                  'red',
                  'blue',
                  'white',
                  'black',
                  'orange',
                  'light blue',
                  'brown',
                  'blue black',
                  'yellow'
                ], (newValue) {
                  setState(() {
                    _selectedUpperClothColor = newValue!;
                  });
                }),
                const SizedBox(height: 10),
                _buildDropdown('Lower Cloth Type:', _selectedLowerClothType,
                    ['trouser', 'shorts', 'nothing', 'boxer'], (newValue) {
                  setState(() {
                    _selectedLowerClothType = newValue!;
                  });
                }),
                const SizedBox(height: 10),
                _buildDropdown('Lower Cloth Color:', _selectedLowerClothColor, [
                  'blue',
                  'black',
                  'white',
                  'red',
                  'orange',
                  'light blue',
                  'brown',
                  'blue black',
                  'yellow'
                ], (newValue) {
                  setState(() {
                    _selectedLowerClothColor = newValue!;
                  });
                }),
              ],
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImages,
                child: const Text('Pick Images'),
              ),
              const SizedBox(height: 10),
              _buildImagePreview(),
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

  Widget _buildTextFormField(TextEditingController controller, String labelText,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 20),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: _images.asMap().entries.map((entry) {
        int index = entry.key;
        File file = entry.value;
        return Stack(
          children: [
            Image.file(file, height: 100, width: 100),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
