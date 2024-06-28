import 'dart:convert';
import 'package:missingpersonapp/features/compare/data/fetchCompare.dart';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
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

  String? _selectedGender = 'Select Gender';
  String? _selectedSkinColor = 'Select Skin Color';
  String? _selectedBodySize = 'Select Body Size';
  String? _selectedUpperClothType = 'Select Upper Cloth Type';
  String? _selectedUpperClothColor = 'Select Upper Cloth Color';
  String? _selectedLowerClothType = 'Select Lower Cloth Type';
  String? _selectedLowerClothColor = 'Select Lower Cloth Color';

  bool _showClothDetails = true;
  bool _showAdditionalDetails = true;
  bool _isLoading = false;

  final List<String> genderItems = ['Select Gender', 'male', 'female'];
  final List<String> skinColorItems = [
    'Select Skin Color',
    'fair',
    'dark',
    'light',
    'brown',
    'black'
  ];
  final List<String> upperClothTypeItems = [
    'Select Upper Cloth Type',
    'tshirt',
    'hoodie',
    'sweater',
    'sweetshirt'
  ];
  final List<String> upperClothColorItems = [
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
  ];
  final List<String> lowerClothTypeItems = [
    'Select Lower Cloth Type',
    'trouser',
    'shorts',
    'nothing',
    'boxer'
  ];
  final List<String> lowerClothColorItems = [
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
  ];

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
        'skin_color': _selectedSkinColor != null &&
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

      print("Person to compare: $personToCompare");

      // Save lastTimeSeen to the state variable
      var _lastTimeSeen = personToCompare['lastTimeSeen'] as int?;

      final url = Uri.parse(
          '${Constants.postUri}/api/features/compare/${_lastTimeSeen}');

      print("URL: $url");

      try {
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(personToCompare),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (responseBody['matchingStatus'] != null) {
            final List<dynamic> matchingStatus = responseBody['matchingStatus'];
            final List<FeatureCompare> featureCompareList =
                FeatureCompare.fromJsonList(matchingStatus);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompareMatchedPersonCard(
                  featureCompareList: featureCompareList,
                  lastTimeSeen: _lastTimeSeen, // Pass lastTimeSeen here
                ),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "No Match Found",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Network error: $e');
        Fluttertoast.showToast(
          msg: "Network error: $e",
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildTextFormField(
                              _firstNameController, 'First Name'),
                          _buildTextFormField(
                              _middleNameController, 'Middle Name'),
                          _buildTextFormField(_lastNameController, 'Last Name'),
                          _buildTextFormField(_ageController, 'Age',
                              isNumeric: true),
                          _buildDropdownButtonFormField(
                              'Gender', genderItems, _selectedGender, (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }),
                          _buildDropdownButtonFormField(
                              'Skin Color', skinColorItems, _selectedSkinColor,
                              (value) {
                            setState(() {
                              _selectedSkinColor = value;
                            });
                          }),
                          _buildTextFormField(
                              _lastPlaceSeenController, 'Last Place Seen'),
                          _buildTextFormField(_lastTimeSeenController,
                              'Last Time Seen (Months)',
                              isNumeric: true),
                          if (_showClothDetails) ...[
                            _buildDropdownButtonFormField(
                                'Upper Cloth Type',
                                upperClothTypeItems,
                                _selectedUpperClothType, (value) {
                              setState(() {
                                _selectedUpperClothType = value;
                              });
                            }),
                            _buildDropdownButtonFormField(
                                'Upper Cloth Color',
                                upperClothColorItems,
                                _selectedUpperClothColor, (value) {
                              setState(() {
                                _selectedUpperClothColor = value;
                              });
                            }),
                            _buildDropdownButtonFormField(
                                'Lower Cloth Type',
                                lowerClothTypeItems,
                                _selectedLowerClothType, (value) {
                              setState(() {
                                _selectedLowerClothType = value;
                              });
                            }),
                            _buildDropdownButtonFormField(
                                'Lower Cloth Color',
                                lowerClothColorItems,
                                _selectedLowerClothColor, (value) {
                              setState(() {
                                _selectedLowerClothColor = value;
                              });
                            }),
                          ],
                          //if (_showAdditionalDetails) ...[
                          _buildTextFormField(
                              _eyeDescriptionController, 'Eye Description'),
                          _buildTextFormField(
                              _noseDescriptionController, 'Nose Description'),
                          _buildTextFormField(
                              _hairDescriptionController, 'Hair Description'),
                          _buildTextFormField(_lastAddressDescController,
                              'Last Address Description'),
                          _buildTextFormField(
                              _medicalInformation, 'Medical Information'),
                          _buildTextFormField(_circumstanceOfDisappearance,
                              'Circumstance Of Disappearance'),
                          // ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _validateAndCompare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // background (button) color
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 60.0, vertical: 15.0), // Button size
                      textStyle:
                          TextStyle(fontSize: 18), // foreground (text) color
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Compare'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String labelText, {
    bool isNumeric = false,
  }) {
    return Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: TextFormField(
    controller: controller,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.blue, // Outline color when text field is active
        ),
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return '$labelText cannot be empty';
      }
      return null;
    },
  ),
);
  }

  Widget _buildDropdownButtonFormField(
    String labelText,
    List<String> items,
    String? selectedItem,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: selectedItem,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value == 'Select $labelText') {
            return 'Please select a $labelText';
          }
          return null;
        },
      ),
    );
  }
}
