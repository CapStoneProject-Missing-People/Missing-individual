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
  final TextEditingController _lastPlaceSeenController = TextEditingController();
  final TextEditingController _lastTimeSeenController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _lastAddressDescController = TextEditingController();
  final TextEditingController _medicalInformation = TextEditingController();
  final TextEditingController _circumstanceOfDisappearance = TextEditingController();
  final TextEditingController _eyeDescriptionController = TextEditingController();
  final TextEditingController _noseDescriptionController = TextEditingController();
  final TextEditingController _hairDescriptionController = TextEditingController();

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
      _showAdditionalDetails = months > 2 || _lastTimeSeenController.text.isEmpty;
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
        'firstName': _firstNameController.text.isNotEmpty ? _firstNameController.text : null,
        'middleName': _middleNameController.text.isNotEmpty ? _middleNameController.text : null,
        'lastName': _lastNameController.text.isNotEmpty ? _lastNameController.text : null,
        'lastSeenLocation': _lastPlaceSeenController.text.isNotEmpty ? _lastPlaceSeenController.text : null,
        'lastTimeSeen': int.tryParse(_lastTimeSeenController.text),
        'gender': _selectedGender != null && _selectedGender != 'Select Gender' ? _selectedGender : null,
        'age': _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
        'skin_color': _selectedSkinColor != null && _selectedSkinColor != 'Select Skin Color' ? _selectedSkinColor : null,
        'upperClothType': _selectedUpperClothType != null && _selectedUpperClothType != 'Select Upper Cloth Type' ? _selectedUpperClothType : null,
        'upperClothColor': _selectedUpperClothColor != null && _selectedUpperClothColor != 'Select Upper Cloth Color' ? _selectedUpperClothColor : null,
        'lowerClothType': _selectedLowerClothType != null && _selectedLowerClothType != 'Select Lower Cloth Type' ? _selectedLowerClothType : null,
        'lowerClothColor': _selectedLowerClothColor != null && _selectedLowerClothColor != 'Select Lower Cloth Color' ? _selectedLowerClothColor : null,
        'bodySize': _selectedBodySize != 'Select Body Size' ? _selectedBodySize : null,
        'eyeDescription': _eyeDescriptionController.text.isNotEmpty ? _eyeDescriptionController.text : null,
        'noseDescription': _noseDescriptionController.text.isNotEmpty ? _noseDescriptionController.text : null,
        'hairDescription': _hairDescriptionController.text.isNotEmpty ? _hairDescriptionController.text : null,
        'lastAddressDesc': _lastAddressDescController.text.isNotEmpty ? _lastAddressDescController.text : null,
        'medicalInformation': _medicalInformation.text.isNotEmpty ? _medicalInformation.text : null,
        'circumstanceOfDisappearance': _circumstanceOfDisappearance.text.isNotEmpty ? _circumstanceOfDisappearance.text : null,
      };

      final url = Uri.parse('${Constants.postUri}/api/features/compare/${personToCompare['lastTimeSeen']}');

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
          final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (responseBody['matchingStatus'] != null) {
            final List<dynamic> matchingStatus = responseBody['matchingStatus'];
            final List<FeatureCompare> featureCompareList = FeatureCompare.fromJsonList(matchingStatus);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_firstNameController, 'First Name'),
                const SizedBox(height: 10),
                _buildTextField(_middleNameController, 'Middle Name'),
                const SizedBox(height: 10),
                _buildTextField(_lastNameController, 'Last Name'),
                const SizedBox(height: 10),
                _buildTextField(_lastTimeSeenController, 'Last Time Seen (in months)', TextInputType.number),
                const SizedBox(height: 10),
                _buildDropdown('Gender:', _selectedGender, genderItems, (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }),
                const SizedBox(height: 10),
                _buildTextField(_ageController, 'Age', TextInputType.number),
                const SizedBox(height: 10),
                _buildDropdown('Skin Color:', _selectedSkinColor, skinColorItems, (newValue) {
                  setState(() {
                    _selectedSkinColor = newValue;
                  });
                }),
                const SizedBox(height: 10),
                _buildTextField(_lastPlaceSeenController, 'Last Place Seen'),
                const SizedBox(height: 10),
                if (_showClothDetails) ...[
                  _buildDropdown('Upper Cloth Type:', _selectedUpperClothType, upperClothTypeItems, (newValue) {
                    setState(() {
                      _selectedUpperClothType = newValue;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildDropdown('Upper Cloth Color:', _selectedUpperClothColor, upperClothColorItems, (newValue) {
                    setState(() {
                      _selectedUpperClothColor = newValue;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildDropdown('Lower Cloth Type:', _selectedLowerClothType, lowerClothTypeItems, (newValue) {
                    setState(() {
                      _selectedLowerClothType = newValue;
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildDropdown('Lower Cloth Color:', _selectedLowerClothColor, lowerClothColorItems, (newValue) {
                    setState(() {
                      _selectedLowerClothColor = newValue;
                    });
                  }),
                  const SizedBox(height: 10),
                ],
                _buildTextField(_eyeDescriptionController, 'Eye Description'),
                const SizedBox(height: 10),
                _buildTextField(_noseDescriptionController, 'Nose Description'),
                const SizedBox(height: 10),
                _buildTextField(_hairDescriptionController, 'Hair Description'),
                const SizedBox(height: 10),
                _buildTextField(_lastAddressDescController, 'Last Address Description'),
                const SizedBox(height: 10),
                _buildTextField(_medicalInformation, 'Medical Information'),
                const SizedBox(height: 10),
                _buildTextField(_circumstanceOfDisappearance, 'Circumstance Of Disappearance'),
                const SizedBox(height: 10),
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
                      : const Text('Compare', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
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
    String? value,
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
}
