import 'dart:convert';
import 'package:missingpersonapp/features/compare/data/fetchCompare.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:missingpersonapp/features/compare/model/compare-model.dart';
import 'package:missingpersonapp/features/compare/screens/card-compare.dart'; // Import the card-compare.dart page

class ComparePersonPage extends StatefulWidget {
  const ComparePersonPage({super.key});

  @override
  _ComparePersonPageState createState() => _ComparePersonPageState();
}

class _ComparePersonPageState extends State<ComparePersonPage> {
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

  String? _selectedGender;
  String? _selectedSkinColor;
  String? _selectedBodySize;
  String? _selectedUpperClothType;
  String? _selectedUpperClothColor;
  String? _selectedLowerClothType;
  String? _selectedLowerClothColor;

  bool _showClothDetails = true;
  bool _showAdditionalDetails = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lastTimeSeenController.addListener(_checkLastTimeSeen);
  }

  void _checkLastTimeSeen() {
    setState(() {
      final months = int.tryParse(_lastTimeSeenController.text) ?? 0;
      _showClothDetails = months <= 2 || _lastTimeSeenController.text.isEmpty;
      _showAdditionalDetails =
          months > 2 || _lastTimeSeenController.text.isEmpty;
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

  Future<Map<String, dynamic>?> postData(
      Map<String, dynamic> personToCompare) async {
    final url = Uri.parse(
        '${Constants.postUri}/api/features/compare/${personToCompare['lastTimeSeen']}');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(personToCompare),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  Future<void> _validateAndCompare() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final personToCompare = {
        'firstName': _firstNameController.text.isNotEmpty
            ? _firstNameController.text
            : null,
        'middleName': _middleNameController.text.isNotEmpty
            ? _middleNameController.text
            : null,
        'lastName': _lastNameController.text.isNotEmpty
            ? _lastNameController.text
            : null,
        'lastSeenLocation': _lastPlaceSeenController.text.isNotEmpty
            ? _lastPlaceSeenController.text
            : null,
        'lastTimeSeen': int.tryParse(_lastTimeSeenController.text),
        'gender': _selectedGender != null && _selectedGender != 'Select Gender'
            ? _selectedGender
            : null,
        'age': _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        'skinColor': _selectedSkinColor != null &&
                _selectedSkinColor != 'Select Skin Color'
            ? _selectedSkinColor
            : null,
        'upperClothType': _selectedUpperClothType != null &&
                _selectedUpperClothType != 'Select Upper Cloth Type'
            ? _selectedUpperClothType
            : null,
        'upperClothColor': _selectedUpperClothColor != null &&
                _selectedUpperClothColor != 'Select Upper Cloth Color'
            ? _selectedUpperClothColor
            : null,
        'lowerClothType': _selectedLowerClothType != null &&
                _selectedLowerClothType != 'Select Lower Cloth Type'
            ? _selectedLowerClothType
            : null,
        'lowerClothColor': _selectedLowerClothColor != null &&
                _selectedLowerClothColor != 'Select Lower Cloth Color'
            ? _selectedLowerClothColor
            : null,
        'bodySize':
            _selectedBodySize != null && _selectedBodySize != 'Select Body Size'
                ? _selectedBodySize
                : null,
        'eyeDescription': _eyeDescriptionController.text.isNotEmpty
            ? _eyeDescriptionController.text
            : null,
        'noseDescription': _noseDescriptionController.text.isNotEmpty
            ? _noseDescriptionController.text
            : null,
        'hairDescription': _hairDescriptionController.text.isNotEmpty
            ? _hairDescriptionController.text
            : null,
        'lastAddressDesc': _lastAddressDescController.text.isNotEmpty
            ? _lastAddressDescController.text
            : null,
        'medicalInformation': _medicalInformation.text.isNotEmpty
            ? _medicalInformation.text
            : null,
        'circumstanceOfDisappearance':
            _circumstanceOfDisappearance.text.isNotEmpty
                ? _circumstanceOfDisappearance.text
                : null,
      };

      final response = await postData(personToCompare);
      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        final matchedPerson = FeatureCompare.fromJson(response);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompareMatchedPersonCard(
                featureCompare:
                    matchedPerson), // Navigate to card-compare.dart with matchedPerson
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "nothing in the database",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Person'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _middleNameController,
                    decoration: const InputDecoration(labelText: 'Middle Name'),
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the last name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: <String>['Select Gender', 'Male', 'Female']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value == 'Select Gender') {
                        return 'Please select a gender';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedSkinColor,
                    decoration: const InputDecoration(labelText: 'Skin Color'),
                    items: <String>[
                      'Select Skin Color',
                      'fair',
                      'dark',
                      'light',
                      'brown',
                      'black'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSkinColor = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value == 'Select Skin Color') {
                        return 'Please select a skin color';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the age';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lastPlaceSeenController,
                    decoration:
                        const InputDecoration(labelText: 'Last Place Seen'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the last place seen';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lastTimeSeenController,
                    decoration: const InputDecoration(
                        labelText: 'Last Time Seen (in months)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the last time seen';
                      }
                      return null;
                    },
                  ),
                  if (_showClothDetails) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedUpperClothType,
                      decoration:
                          const InputDecoration(labelText: 'Upper Cloth Type'),
                      items: <String>[
                        'Select Upper Cloth Type',
                        'tshirt',
                        'hoodie',
                        'sweater',
                        'sweetshirt'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUpperClothType = newValue;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedUpperClothColor,
                      decoration:
                          const InputDecoration(labelText: 'Upper Cloth Color'),
                      items: <String>[
                        'Select Upper Cloth Color',
                        'red',
                        'blue',
                        'white',
                        'black',
                        'orange',
                        'light blue',
                        'brown',
                        'blue black',
                        'yellow'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUpperClothColor = newValue;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedLowerClothType,
                      decoration:
                          const InputDecoration(labelText: 'Lower Cloth Type'),
                      items: <String>[
                        'Select Lower Cloth Type',
                        'trouser',
                        'shorts',
                        'nothing',
                        'boxer'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLowerClothType = newValue;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedLowerClothColor,
                      decoration:
                          const InputDecoration(labelText: 'Lower Cloth Color'),
                      items: <String>[
                        'Select Lower Cloth Color',
                        'blue',
                        'black',
                        'white',
                        'red',
                        'orange',
                        'light blue',
                        'brown',
                        'blue black',
                        'yellow'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLowerClothColor = newValue;
                        });
                      },
                    ),
                  ],
                  if (_showAdditionalDetails) ...[
                    TextFormField(
                      controller: _eyeDescriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Eye Description'),
                    ),
                    TextFormField(
                      controller: _noseDescriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Nose Description'),
                    ),
                    TextFormField(
                      controller: _hairDescriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Hair Description'),
                    ),
                    TextFormField(
                      controller: _lastAddressDescController,
                      decoration: const InputDecoration(
                          labelText: 'Last Address Description'),
                    ),
                    TextFormField(
                      controller: _medicalInformation,
                      decoration: const InputDecoration(
                          labelText: 'Medical Information'),
                    ),
                    TextFormField(
                      controller: _circumstanceOfDisappearance,
                      decoration: const InputDecoration(
                          labelText: 'Circumstance of Disappearance'),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _validateAndCompare,
                    child: const Text('compare'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
