import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:missingpersonapp/features/authentication/utils/constants.dart';
import 'package:missingpersonapp/features/compare/model/compare-model.dart';
import 'package:missingpersonapp/features/compare/screens/card-compare.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart'; // Import the Glassmorphic Button

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
  final String _selectedBodySize = 'Select Body Size';
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
            _selectedBodySize != 'Select Body Size' ? _selectedBodySize : null,
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

      final url = Uri.parse(
          '${Constants.postUri}/api/features/compare/${personToCompare['lastTimeSeen']}');

      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(personToCompare),
        );

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
                  lastTimeSeen: personToCompare['lastTimeSeen'] as int?,
                ),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "No Match Found",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "Network error: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
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
              children: [
                _buildGlassCard(
                  children: [
                    _buildTextFormField(_firstNameController, 'First Name'),
                    _buildTextFormField(_middleNameController, 'Middle Name'),
                    _buildTextFormField(_lastNameController, 'Last Name'),
                    _buildTextFormField(_ageController, 'Age', isNumeric: true),
                    _buildDropdown('Gender', genderItems, _selectedGender,
                        (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    }),
                    _buildDropdown(
                        'Skin Color', skinColorItems, _selectedSkinColor,
                        (value) {
                      setState(() {
                        _selectedSkinColor = value;
                      });
                    }),
                    _buildTextFormField(
                        _lastPlaceSeenController, 'Last Place Seen'),
                    _buildTextFormField(
                        _lastTimeSeenController, 'Last Time Seen (Months)',
                        isNumeric: true),
                    if (_showClothDetails) ...[
                      _buildDropdown('Upper Cloth Type', upperClothTypeItems,
                          _selectedUpperClothType, (value) {
                        setState(() {
                          _selectedUpperClothType = value;
                        });
                      }),
                      _buildDropdown('Upper Cloth Color', upperClothColorItems,
                          _selectedUpperClothColor, (value) {
                        setState(() {
                          _selectedUpperClothColor = value;
                        });
                      }),
                      _buildDropdown('Lower Cloth Type', lowerClothTypeItems,
                          _selectedLowerClothType, (value) {
                        setState(() {
                          _selectedLowerClothType = value;
                        });
                      }),
                      _buildDropdown('Lower Cloth Color', lowerClothColorItems,
                          _selectedLowerClothColor, (value) {
                        setState(() {
                          _selectedLowerClothColor = value;
                        });
                      }),
                    ],
                    _buildTextFormField(
                        _eyeDescriptionController, 'Eye Description'),
                    _buildTextFormField(
                        _noseDescriptionController, 'Nose Description'),
                    _buildTextFormField(
                        _hairDescriptionController, 'Hair Description'),
                    _buildTextFormField(
                        _lastAddressDescController, 'Last Address Description'),
                    _buildTextFormField(
                        _medicalInformation, 'Medical Information'),
                    _buildTextFormField(_circumstanceOfDisappearance,
                        'Circumstance Of Disappearance'),
                  ],
                ),
                const SizedBox(height: 20),
                GlassmorphismButton(
                  onPressed: _isLoading
                      ? () {} // Fallback empty function when loading
                      : () async {
                          if (!_isLoading) {
                            await _validateAndCompare();
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Compare',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String labelText, List<String> items,
      String? selectedItem, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
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
        dropdownColor: Colors.grey.shade800,
        style: const TextStyle(color: Colors.white),
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
