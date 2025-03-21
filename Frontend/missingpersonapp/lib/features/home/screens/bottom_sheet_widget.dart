import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';

class MyDraggableSheet extends StatefulWidget {
  final bool visible;
  final Widget child;
  final Function onFilterChanged;
  final Function onClose;

  const MyDraggableSheet({
    super.key,
    required this.visible,
    required this.child,
    required this.onFilterChanged,
    required this.onClose,
  });

  @override
  _MyDraggableSheetState createState() => _MyDraggableSheetState();
}

class _MyDraggableSheetState extends State<MyDraggableSheet> {
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  int? _minAge;
  int? _maxAge;
  String? _weight;
  String? _gender;
  String? _skinColor;

  @override
  void initState() {
    super.initState();
    _controller.addListener(onChanged);
  }

  void onChanged() {
    final currentSize = _controller.size;
    if (currentSize <= 0.05) collapse();
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);

  void anchor() => animateSheet(getSheet.snapSizes!.last);

  void expand() => animateSheet(getSheet.maxChildSize);

  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double size) {
    _controller.animateTo(
      size,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _applyFilter() {
    widget.onFilterChanged({
      'minAge': _minAge,
      'maxAge': _maxAge,
      'weight': _weight,
      'gender': _gender,
      'skinColor': _skinColor,
    });
  }

  void _clearFilter() {
    setState(() {
      _minAge = null;
      _maxAge = null;
      _weight = null;
      _gender = null;
      _skinColor = null;
      _minAgeController.clear();
      _maxAgeController.clear();
    });
    _applyFilter();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
  }

  DraggableScrollableSheet get getSheet =>
      _sheetKey.currentWidget as DraggableScrollableSheet;

  final GlobalKey _sheetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Stack(
        children: [
          // Click outside to close
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                hide();
                Future.delayed(const Duration(milliseconds: 200), () {
                  widget.onClose();
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            return DraggableScrollableSheet(
              key: _sheetKey,
              initialChildSize: 0.6,
              maxChildSize: 0.95,
              minChildSize: 0,
              expand: true,
              snap: true,
              snapSizes: [40 / constraints.maxHeight, 0.5],
              controller: _controller,
              builder: (BuildContext context, ScrollController scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.grey.shade800],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Indicator
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Filters',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          hide();
                                          Future.delayed(
                                              const Duration(milliseconds: 200), () {
                                            widget.onClose();
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Age Filter
                                  _buildAgeFilter(),
                                  const SizedBox(height: 16),
                                  // Weight Filter
                                  _buildWeightFilter(),
                                  const SizedBox(height: 16),
                                  // Gender Filter
                                  _buildGenderFilter(),
                                  const SizedBox(height: 16),
                                  // Skin Color Filter
                                  _buildSkinColorFilter(),
                                  const SizedBox(height: 16),
                                  // Clear Filters Button
                                  Center(
                              child: GlassmorphismButton(
                                onPressed: _clearFilter,
                                child: const Text(
                                  'Clear Filters',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAgeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Age',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Min Age: ${_minAge?.toString() ?? 'Any'}',
                style: const TextStyle(color: Colors.white)),
            Text('Max Age: ${_maxAge?.toString() ?? 'Any'}',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: Colors.blueAccent,
            overlayColor: Colors.blueAccent.withOpacity(0.2),
            valueIndicatorColor: Colors.blueAccent,
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: RangeSlider(
            values: RangeValues(
              (_minAge?.toDouble() ?? 0).clamp(0, 150),
              (_maxAge?.toDouble() ?? 150).clamp(0, 150),
            ),
            min: 0,
            max: 150,
            divisions: 150,
            labels: RangeLabels(
              _minAge?.toString() ?? '0',
              _maxAge?.toString() ?? '150',
            ),
            onChanged: (RangeValues values) {
              if (values.start < 0 || values.end > 150) {
                Fluttertoast.showToast(
                  msg: 'Age must be between 0 and 150',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              } else {
                setState(() {
                  _minAge = values.start.toInt();
                  _maxAge = values.end.toInt();
                  _applyFilter();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: _weight,
            hint: const Text('Any', style: TextStyle(color: Colors.white70)),
            onChanged: (String? newValue) {
              setState(() {
                _weight = newValue;
                _applyFilter();
              });
            },
            items: const [
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
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            dropdownColor: Colors.grey.shade900,
            icon: const Icon(Icons.arrow_drop_down_outlined,
                color: Colors.white70),
            isExpanded: true,
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGenderButton('Male', Icons.male_outlined),
            _buildGenderButton('Female', Icons.female_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, IconData icon) {
    final bool isSelected = _gender?.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = isSelected ? null : label.toLowerCase();
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinColorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skin Color',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: _skinColor,
            hint: const Text('Any', style: TextStyle(color: Colors.white70)),
            onChanged: (String? newValue) {
              setState(() {
                _skinColor = newValue;
                _applyFilter();
              });
            },
            items: const [
              'fair',
              'black',
              'white',
              'teyim',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            dropdownColor: Colors.grey.shade900,
            icon: const Icon(Icons.arrow_drop_down_outlined,
                color: Colors.white70),
            isExpanded: true,
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }
}
