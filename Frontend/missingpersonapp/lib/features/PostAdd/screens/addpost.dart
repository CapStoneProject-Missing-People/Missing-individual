import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/features/PostAdd/models/addpost_model.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  final List<File> _images = [];
  bool _isFirstTime = true;
  bool _showClothDetails = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _lastTimeSeenController.addListener(_checkLastTimeSeen);
    _checkFirstTime().then((_) {
      if (_isFirstTime) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFirstTimeTooltips(context);
        });
      }
    });
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
    _medicalInformation.dispose();
    _circumstanceOfDisappearance.dispose();
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
    final authService = Provider.of<AuthService>(context, listen: false);
    final url = Uri.parse(
        '${Constants.postUri}/api/createMissingPerson/${missingPerson.lastTimeSeen}');

    try {
      final accessToken = await authService.getValidAccessToken(context);
      if (accessToken == null) {
        Fluttertoast.showToast(
          msg: 'Authentication failed. Please log in again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
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
      request.fields['medicalInformation'] = _medicalInformation.text;
      request.fields['circumstanceOfDisappearance'] =
          _circumstanceOfDisappearance.text;

      for (var i = 0; i < _images.length; i++) {
        request.files
            .add(await http.MultipartFile.fromPath('images', _images[i].path));
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
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
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

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
    if (_isFirstTime) {
      prefs.setBool('isFirstTime', false);
    }
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
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

  void _openImagePreview(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _images[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFirstTimeTooltips(BuildContext context) {
    if (_isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text(
                'How to Use the Image Picker',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Tap an image to view it in full screen.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '2. Swipe an image to remove it.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Got it!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_firstNameController, 'First Name'),
                const SizedBox(height: 10),
                _buildTextField(_middleNameController, 'Middle Name'),
                const SizedBox(height: 10),
                _buildTextField(_lastNameController, 'Last Name'),
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
                _buildTextField(_eyeDescriptionController, 'Eye Description'),
                const SizedBox(height: 10),
                _buildTextField(_noseDescriptionController, 'Nose Description'),
                const SizedBox(height: 10),
                _buildTextField(_hairDescriptionController, 'Hair Description'),
                if (_showClothDetails) ...[
                  const SizedBox(height: 10),
                  _buildDropdown('Upper Cloth Type:', _selectedUpperClothType, [
                    'tshirt',
                    'hoodie',
                    'sweater',
                    'sweetshirt'
                  ], (newValue) {
                    setState(() {
                      _selectedUpperClothType = newValue!;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildDropdown(
                      'Upper Cloth Color:', _selectedUpperClothColor, [
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
                  _buildDropdown(
                      'Lower Cloth Color:', _selectedLowerClothColor, [
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
                  const SizedBox(height: 10),
                  _buildTextField(_lastPlaceSeenController, 'Last Place Seen'),
                ],
                const SizedBox(height: 10),
                _buildTextField(_medicalInformation, "Medical Information"),
                const SizedBox(height: 10),
                _buildTextField(_circumstanceOfDisappearance,
                    "Circumstance of Disappearance"),
                const SizedBox(height: 10),
                GlassmorphismButton(
                  onPressed: pickImages,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Images',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildImageGrid(),
                const SizedBox(height: 10),
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  GlassmorphismButton(
                    onPressed: _validateAndSubmit,
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
              ],
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
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white70),
        ),
      ),
      dropdownColor: Colors.grey.shade800,
      style: const TextStyle(color: Colors.white),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImageGrid() {
    return _images.isEmpty
        ? const Center(
            child: Text(
              'No images selected.',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns
              crossAxisSpacing: 8.0, // Horizontal spacing between items
              mainAxisSpacing: 8.0, // Vertical spacing between items
              childAspectRatio: 1, // Square aspect ratio (1:1)
            ),
            itemCount: _images.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(_images[index].path),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) => _removeImage(index),
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _openImagePreview(context, index),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _images[index],
                        fit: BoxFit
                            .cover, // Crop the image to fill the container
                        width: double.infinity, // Ensure full width
                        height: double.infinity, // Ensure full height
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
