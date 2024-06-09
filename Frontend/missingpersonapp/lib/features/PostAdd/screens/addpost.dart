import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/features/PostAdd/models/addpost_model.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
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
  final TextEditingController _lastPlaceSeenController = TextEditingController();
  final TextEditingController _lastTimeSeenController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _eyeDescriptionController = TextEditingController();
  final TextEditingController _noseDescriptionController = TextEditingController();
  final TextEditingController _hairDescriptionController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedSkinColor = 'fair';
  String _selectedBodySize = 'thin';
  String _selectedUpperClothType = 'tshirt';
  String _selectedUpperClothColor = 'red';
  String _selectedLowerClothType = 'trouser';
  String _selectedLowerClothColor = 'blue';

  List<File> _images = [];
  bool _showClothDetails = true;
  bool _isSubmitting = false;

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

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      final missingPerson = MissingPersonAddingModel(
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

      final success = await postData(missingPerson);
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<bool> postData(MissingPersonAddingModel missingPerson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authorization');
    final url = Uri.parse('${Constants.postUri}/api/createMissingPerson/${missingPerson.lastTimeSeen}');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['firstName'] = missingPerson.firstName;
      request.fields['middleName'] = missingPerson.middleName;
      request.fields['lastName'] = missingPerson.lastName;
      request.fields['last_place_seen'] = missingPerson.lastPlaceSeen;
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

      for (var i = 0; i < _images.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          _images[i].path,
        ));
      }

      var response = await request.send();
      final decodedResponse = await response.stream.bytesToString();
      final parsedResponse = jsonDecode(decodedResponse);

      if (response.statusCode == 201) {
        final message = parsedResponse['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return true;
      } else {
        final message = parsedResponse['message'];
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Network error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        for (var file in pickedFiles) {
          if (_images.any((existingFile) => existingFile.path == file.path)) {
            Fluttertoast.showToast(
              msg: 'Duplicate image: ${file.name}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            _images.add(File(file.path));
          }
        }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Card(
            color: Colors.white,
            shadowColor: Colors.grey[200],
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_firstNameController, 'First Name'),
                  const SizedBox(height: 10),
                  _buildTextField(_middleNameController, 'Middle Name'),
                  const SizedBox(height: 10),
                  _buildTextField(_lastNameController, 'Last Name'),
                  const SizedBox(height: 10),
                  _buildTextField(_lastPlaceSeenController, 'Last Place Seen'),
                  const SizedBox(height: 10),
                  _buildTextField(_lastTimeSeenController,
                      'Last Time Seen (in months)', TextInputType.number),
                  const SizedBox(height: 10),
                  _buildDropdown('Gender:', _selectedGender, ['male', 'female'],
                      (newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildTextField(_ageController, 'Age', TextInputType.number),
                  const SizedBox(height: 10),
                  _buildDropdown('Skin Color:', _selectedSkinColor,
                      ['fair', 'black', 'white', 'tseyim'], (newValue) {
                    setState(() {
                      _selectedSkinColor = newValue!;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildDropdown('Body Size:', _selectedBodySize,
                      ['thin', 'average','muscular','overweight', 'obese','fit','athletic','curvy','petite','fat'], (newValue) {
                    setState(() {
                      _selectedBodySize = newValue!;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildTextField(_eyeDescriptionController, 'Eye Description'),
                  const SizedBox(height: 10),
                  _buildTextField(_noseDescriptionController, 'Nose Description'),
                  const SizedBox(height: 10),
                  _buildTextField(_hairDescriptionController, 'Hair Description'),
                  if (_showClothDetails) ...[
                    const SizedBox(height: 10),
                    _buildDropdown('Upper Cloth Type:', _selectedUpperClothType,
                        ['tshirt','hoodie','sweater','sweetshirt'], (newValue) {
                      setState(() {
                        _selectedUpperClothType = newValue!;
                      });
                    }),
                    const SizedBox(height: 10),
                    _buildDropdown('Upper Cloth Color:', _selectedUpperClothColor,
                        ['red', 'blue', 'white', 'black','orange','light blue','brown','blue black','yellow'], (newValue) {
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
                    _buildDropdown('Lower Cloth Color:', _selectedLowerClothColor,
                        ['blue','black','white','red','orange', 'light blue','brown','blue black','yellow'], (newValue) {
                      setState(() {
                        _selectedLowerClothColor = newValue!;
                      });
                    }),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Images'),
                  ),
                  const SizedBox(height: 10),
                  _buildImageGrid(),
                  const SizedBox(height: 10),
                  if (_isSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _validateAndSubmit,
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          hintText: 'Enter the $label',
          hintStyle: TextStyle(color: Colors.blue[200]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blueAccent,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: value,
            icon: const Icon(Icons.arrow_downward, color: Colors.blue),
            iconSize: 24,
            elevation: 16,
            underline: Container(
              height: 2,
              color: Colors.transparent,
            ),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  width: 90,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return _images.isEmpty
        ? const Text('No images selected.')
        : SizedBox(
            height: 80, // Adjust the height as needed
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 80, // Adjust the width as needed
                      child: Image.file(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }
}
