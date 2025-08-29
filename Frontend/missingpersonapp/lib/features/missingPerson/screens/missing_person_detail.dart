import 'dart:convert';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/features/missingPerson/models/missing_person_model.dart';
import 'package:missingpersonapp/features/missingPerson/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class MissingPersonDetails extends StatefulWidget {
  final MissingPersonSpecific missingPerson;

  const MissingPersonDetails({super.key, required this.missingPerson});

  @override
  State<MissingPersonDetails> createState() => _MissingPersonDetailsState();
}

class _MissingPersonDetailsState extends State<MissingPersonDetails> {
  int activeIndex = 0;
  List<Uint8List> photos = [];
  final PageController _pageController = PageController();
  late MissingPersonSpecific _missingPerson;
  String? _phoneNo;
  bool _isSubmitting = false;
  bool _showClothDetails = true;
  bool _isDialogOpen = false;

  // Additional controllers for fields from MissingPersonAddPage
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _eyeDescriptionController =
      TextEditingController();
  final TextEditingController _noseDescriptionController =
      TextEditingController();
  final TextEditingController _hairDescriptionController =
      TextEditingController();
  final TextEditingController _medicalInformationController =
      TextEditingController();
  final TextEditingController _circumstanceOfDisappearanceController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    photos = List.from(widget.missingPerson.photos);
    _missingPerson = widget.missingPerson;
    _phoneNo = Provider.of<UserProvider>(context, listen: false).user.phoneNo;
    final descriptionParts = _parseDescription(_missingPerson.description);
    _middleNameController.text = descriptionParts['middleName'] ?? '';
    _eyeDescriptionController.text = descriptionParts['eyeDescription'] ?? '';
    _noseDescriptionController.text = descriptionParts['noseDescription'] ?? '';
    _hairDescriptionController.text = descriptionParts['hairDescription'] ?? '';
    _medicalInformationController.text =
        descriptionParts['medicalInformation'] ?? '';
    _circumstanceOfDisappearanceController.text =
        descriptionParts['circumstanceOfDisappearance'] ?? '';
    _checkClothDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _middleNameController.dispose();
    _eyeDescriptionController.dispose();
    _noseDescriptionController.dispose();
    _hairDescriptionController.dispose();
    _medicalInformationController.dispose();
    _circumstanceOfDisappearanceController.dispose();
    super.dispose();
  }

  void _checkClothDetails() {
    setState(() {
      _showClothDetails = _missingPerson.timeSinceDisappearance <= 2;
    });
  }

  Map<String, String> _parseDescription(String description) {
    try {
      final Map<String, dynamic> parsed = jsonDecode(description);
      return {
        'middleName': parsed['middleName'] ?? '',
        'eyeDescription': parsed['eyeDescription'] ?? '',
        'noseDescription': parsed['noseDescription'] ?? '',
        'hairDescription': parsed['hairDescription'] ?? '',
        'medicalInformation': parsed['medicalInformation'] ?? '',
        'circumstanceOfDisappearance':
            parsed['circumstanceOfDisappearance'] ?? '',
      };
    } catch (e) {
      return {
        'middleName': '',
        'eyeDescription': '',
        'noseDescription': '',
        'hairDescription': '',
        'medicalInformation': '',
        'circumstanceOfDisappearance': '',
      };
    }
  }

  String _combineDescription() {
    final Map<String, String> descriptionMap = {
      'middleName': _middleNameController.text,
      'eyeDescription': _eyeDescriptionController.text,
      'noseDescription': _noseDescriptionController.text,
      'hairDescription': _hairDescriptionController.text,
      'medicalInformation': _medicalInformationController.text,
      'circumstanceOfDisappearance':
          _circumstanceOfDisappearanceController.text,
    };
    return jsonEncode(descriptionMap);
  }

  Future<void> _editField(
    BuildContext context,
    String field,
    String currentValue,
    ValueSetter<String> onSaveLocal, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool isDropdown = false,
    List<String> dropdownItems = const [],
  }) async {
    if (_isDialogOpen) return;
    setState(() => _isDialogOpen = true);

    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    String? selectedValue = currentValue;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isLoading = false;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 24,
                            semanticLabel: 'Edit',
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "Edit $field",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              semanticsLabel: "Edit $field",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isDropdown)
                        TextFormField(
                          controller: controller,
                          autofocus: true,
                          keyboardType: keyboardType,
                          maxLines: maxLines,
                          minLines: maxLines > 1 ? 3 : 1,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Enter new $field",
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.white70,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.redAccent,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          validator:
                              validator ??
                              (value) {
                                if (value == null || value.isEmpty)
                                  return '$field is required';
                                return null;
                              },
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: selectedValue,
                          items: dropdownItems
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            selectedValue = value;
                          },
                          decoration: InputDecoration(
                            labelText: field,
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.white70,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          dropdownColor: Colors.grey.shade800,
                          style: const TextStyle(color: Colors.white),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          validator: (value) =>
                              value == null ? 'Please select a $field' : null,
                        ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                semanticsLabel: "Cancel",
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GlassmorphismButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  setDialogState(() => isLoading = true);
                                  final newValue = isDropdown
                                      ? selectedValue!
                                      : controller.text;
                                  Navigator.pop(context, newValue);
                                }
                              },
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                semanticsLabel: "Save",
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    setState(() => _isDialogOpen = false);

    if (result != null && result != currentValue) {
      setState(() {
        onSaveLocal(result);
      });
      try {
        final fieldMap = {
          'First Name': 'firstName',
          'Middle Name': 'middleName',
          'Last Name': 'lastName',
          'Age': 'age',
          'Gender': 'gender',
          'Skin Color': 'skin_color',
          'Body Size': 'body_size',
          'Upper Cloth Type': 'clothingUpperClothType',
          'Upper Cloth Color': 'clothingUpperClothColor',
          'Lower Cloth Type': 'clothingLowerClothType',
          'Lower Cloth Color': 'clothingLowerClothColor',
          'Last Place Seen': 'last_place_seen',
          'Last Time Seen': 'last_time_seen',
          'Eye Description': 'eyeDescription',
          'Nose Description': 'noseDescription',
          'Hair Description': 'hairDescription',
          'Medical Information': 'medicalInformation',
          'Circumstance of Disappearance': 'circumstanceOfDisappearance',
        };
        final backendField = fieldMap[field] ?? field.toLowerCase();
        await Provider.of<MissingPersonProvider>(
          context,
          listen: false,
        ).updateMissingPersonField(
          _missingPerson,
          backendField,
          result,
          context,
        );
        if ([
          'Middle Name',
          'Eye Description',
          'Nose Description',
          'Hair Description',
          'Medical Information',
          'Circumstance of Disappearance',
        ].contains(field)) {
          _missingPerson.description = _combineDescription();
          await Provider.of<MissingPersonProvider>(
            context,
            listen: false,
          ).updateMissingPersonField(
            _missingPerson,
            'description',
            _missingPerson.description,
            context,
          );
        }
        Fluttertoast.showToast(
          msg: '$field updated successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (error) {
        print('Error updating $field: $error');
        Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        photos.add(bytes);
      });
    }
  }

  Future<void> _submitImages() async {
    if (_isDialogOpen) return;
    setState(() => _isDialogOpen = true);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Confirm Image Submission',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    semanticsLabel: 'Confirm Image Submission',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure you want to submit these images?',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          semanticsLabel: 'Cancel',
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GlassmorphismButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          semanticsLabel: 'Submit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    setState(() => _isDialogOpen = false);

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await Provider.of<MissingPersonProvider>(
        context,
        listen: false,
      ).updateMissingPersonPhotos(_missingPerson, photos, context);
      Fluttertoast.showToast(
        msg: 'Images updated successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (error) {
      print('Error updating images: $error');
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget buildDetailRow(
    String title,
    String value,
    IconData icon,
    ValueSetter<String> onSaveLocal, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool isDropdown = false,
    List<String> dropdownItems = const [],
    bool isInRow = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_isDialogOpen) {
          _editField(
            context,
            title,
            value,
            onSaveLocal,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            isDropdown: isDropdown,
            dropdownItems: dropdownItems,
          );
        }
      },
      child: Semantics(
        button: true,
        label: 'Edit $title',
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                    semanticLabel: title,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          semanticsLabel: title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          semanticsLabel: value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: maxLines > 1 ? TextOverflow.ellipsis : null,
                          maxLines: maxLines > 1 ? 3 : 1,
                        ),
                      ],
                    ),
                  ),
                  if (isInRow)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue.withOpacity(0.6),
                        size: 16,
                      ),
                    ),
                ],
              ),
              if (!isInRow)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final detailsPerSlide = screenHeight < 600 ? 3 : 4;
    final hasNewImages =
        photos.length > widget.missingPerson.photos.length ||
        photos.any((photo) => !widget.missingPerson.photos.contains(photo));

    final List<Widget> allDetails = [
      buildDetailRow(
        'First Name',
        _missingPerson.name.firstName,
        Icons.person_outline,
        (newValue) => setState(() {
          _missingPerson.name.firstName = newValue;
        }),
        keyboardType: TextInputType.name,
      ),
      buildDetailRow(
        'Middle Name',
        _middleNameController.text,
        Icons.person_outline,
        (newValue) => setState(() {
          _middleNameController.text = newValue;
        }),
        keyboardType: TextInputType.name,
      ),
      buildDetailRow(
        'Last Name',
        _missingPerson.name.lastName,
        Icons.person_outline,
        (newValue) => setState(() {
          _missingPerson.name.lastName = newValue;
        }),
        keyboardType: TextInputType.name,
      ),
      Row(
        children: [
          Expanded(
            child: buildDetailRow(
              'Gender',
              _missingPerson.gender,
              _missingPerson.gender.toLowerCase() == 'female'
                  ? Icons.female_outlined
                  : Icons.male_outlined,
              (newValue) => setState(() {
                _missingPerson.gender = newValue;
              }),
              isDropdown: true,
              dropdownItems: ['male', 'female'],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: buildDetailRow(
              'Age',
              _missingPerson.age.toString(),
              Icons.cake_outlined,
              (newValue) => setState(() {
                _missingPerson.age = int.parse(newValue);
              }),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Age is required';
                if (int.tryParse(value) == null) return 'Age must be a number';
                return null;
              },
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: buildDetailRow(
              'Skin Color',
              _missingPerson.skin_color,
              Icons.palette_outlined,
              (newValue) => setState(() {
                _missingPerson.skin_color = newValue;
              }),
              isDropdown: true,
              dropdownItems: ['fair', 'black', 'white', 'tseyim'],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: buildDetailRow(
              'Body Size',
              _missingPerson.body_size,
              Icons.accessibility_outlined,
              (newValue) => setState(() {
                _missingPerson.body_size = newValue;
              }),
              isDropdown: true,
              dropdownItems: [
                'thin',
                'average',
                'muscular',
                'overweight',
                'obese',
                'fit',
                'athletic',
                'curvy',
                'petite',
                'fat',
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: buildDetailRow(
              'Last Time Seen',
              _missingPerson.timeSinceDisappearance.toString(),
              Icons.timer_outlined,
              (newValue) => setState(() {
                _missingPerson.timeSinceDisappearance = int.parse(newValue);
                _checkClothDetails();
              }),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Last Time Seen is required';
                if (int.tryParse(value) == null) return 'Must be a number';
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: SizedBox(),
          ), // Placeholder for empty second column
        ],
      ),
      if (_showClothDetails) ...[
        Row(
          children: [
            Expanded(
              child: buildDetailRow(
                'Upper Cloth Type',
                _missingPerson.clothing.upper.clothType,
                Icons.checkroom_outlined,
                (newValue) => setState(() {
                  _missingPerson.clothing.upper.clothType = newValue;
                }),
                isDropdown: true,
                dropdownItems: ['tshirt', 'hoodie', 'sweater', 'sweetshirt'],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildDetailRow(
                'Upper Cloth Color',
                _missingPerson.clothing.upper.clothColor,
                Icons.color_lens_outlined,
                (newValue) => setState(() {
                  _missingPerson.clothing.upper.clothColor = newValue;
                }),
                isDropdown: true,
                dropdownItems: [
                  'red',
                  'blue',
                  'white',
                  'black',
                  'orange',
                  'light blue',
                  'brown',
                  'blue black',
                  'yellow',
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildDetailRow(
                'Lower Cloth Type',
                _missingPerson.clothing.lower.clothType,
                Icons.checkroom_outlined,
                (newValue) => setState(() {
                  _missingPerson.clothing.lower.clothType = newValue;
                }),
                isDropdown: true,
                dropdownItems: ['trouser', 'shorts', 'nothing', 'boxer'],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildDetailRow(
                'Lower Cloth Color',
                _missingPerson.clothing.lower.clothColor,
                Icons.color_lens_outlined,
                (newValue) => setState(() {
                  _missingPerson.clothing.lower.clothColor = newValue;
                }),
                isDropdown: true,
                dropdownItems: [
                  'blue',
                  'black',
                  'white',
                  'red',
                  'orange',
                  'light blue',
                  'brown',
                  'blue black',
                  'yellow',
                ],
              ),
            ),
          ],
        ),
        buildDetailRow(
          'Last Place Seen',
          _missingPerson.lastSeenLocation,
          Icons.location_on_outlined,
          (newValue) => setState(() {
            _missingPerson.lastSeenLocation = newValue;
          }),
          keyboardType: TextInputType.text,
        ),
      ],
      buildDetailRow(
        'Eye Description',
        _eyeDescriptionController.text,
        Icons.remove_red_eye_outlined,
        (newValue) => setState(() {
          _eyeDescriptionController.text = newValue;
        }),
        keyboardType: TextInputType.text,
      ),
      buildDetailRow(
        'Nose Description',
        _noseDescriptionController.text,
        Icons.face_outlined,
        (newValue) => setState(() {
          _noseDescriptionController.text = newValue;
        }),
        keyboardType: TextInputType.text,
      ),
      buildDetailRow(
        'Hair Description',
        _hairDescriptionController.text,
        Icons.brush_outlined,
        (newValue) => setState(() {
          _hairDescriptionController.text = newValue;
        }),
        keyboardType: TextInputType.text,
      ),
      buildDetailRow(
        'Medical Information',
        _medicalInformationController.text,
        Icons.medical_services_outlined,
        (newValue) => setState(() {
          _medicalInformationController.text = newValue;
        }),
        keyboardType: TextInputType.multiline,
        maxLines: 3,
      ),
      buildDetailRow(
        'Circumstance of Disappearance',
        _circumstanceOfDisappearanceController.text,
        Icons.info_outlined,
        (newValue) => setState(() {
          _circumstanceOfDisappearanceController.text = newValue;
        }),
        keyboardType: TextInputType.multiline,
        maxLines: 3,
      ),
    ];

    final List<List<Widget>> detailSlides = [];
    for (var i = 0; i < allDetails.length; i += detailsPerSlide) {
      detailSlides.add(
        allDetails.sublist(
          i,
          i + detailsPerSlide > allDetails.length
              ? allDetails.length
              : i + detailsPerSlide,
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 85), // Space for app bar-like area
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CarouselSlider.builder(
                        itemCount: photos.length + 1,
                        itemBuilder: (context, index, realIndex) {
                          if (index < photos.length) {
                            final imageBytes = photos[index];
                            return Stack(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height:
                                      MediaQuery.of(context).size.width *
                                      0.7 *
                                      4 /
                                      3,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      imageBytes,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Semantics(
                                    button: true,
                                    label: 'Delete image',
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(() {
                                        photos.removeAt(index);
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (index == photos.length - 1 && hasNewImages)
                                  Positioned(
                                    top: 8,
                                    left: 18,
                                    child: Semantics(
                                      button: true,
                                      label: 'Submit images',
                                      child: SizedBox(
                                        width: 100,
                                        child: GlassmorphismButton(
                                          onPressed: _isSubmitting
                                              ? () {}
                                              : () => _submitImages(),
                                          child: _isSubmitting
                                              ? const CircularProgressIndicator(
                                                  color: Colors.blue,
                                                  strokeWidth: 2,
                                                )
                                              : const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          } else {
                            return Semantics(
                              button: true,
                              label: 'Add photo',
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _pickImage,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height:
                                      MediaQuery.of(context).size.width *
                                      0.7 *
                                      4 /
                                      3,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 36,
                                      color: Colors.blue.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        options: CarouselOptions(
                          aspectRatio: 4 / 3,
                          enlargeCenterPage: true,
                          viewportFraction: 0.75,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) =>
                              setState(() => activeIndex = index),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '${_missingPerson.name.firstName} ${_middleNameController.text} ${_missingPerson.name.lastName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            semanticsLabel:
                                '${_missingPerson.name.firstName} ${_middleNameController.text} ${_missingPerson.name.lastName}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: photos.length > 0
                        ? buildIndicator(activeIndex, photos.length + 1)
                        : Container(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Swipe for more details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          semanticsLabel: 'Swipe for more details',
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: screenHeight * 0.5,
                      child: PageView(
                        controller: _pageController,
                        children: detailSlides
                            .map((details) => Column(children: details))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              top: 25,
              left: 10,
              child: GlassmorphismButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate to the previous page
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator(int activeIndex, int count) => AnimatedSmoothIndicator(
        effect: const ExpandingDotsEffect(
          dotWidth: 8,
          activeDotColor: Colors.blue,
          dotColor: Colors.white70,
          spacing: 6,
        ),
        activeIndex: activeIndex,
        count: count,
      );

  Widget buildImage(Uint8List imageBytes, int index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7 * 4 / 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}