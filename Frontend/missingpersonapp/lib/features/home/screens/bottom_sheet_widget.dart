import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyDraggableSheet extends StatefulWidget {
  final bool visible;
  final Widget child;
  final Function onFilterChanged;
  final Function onClose;

  MyDraggableSheet({
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
  final GlobalKey _sheetKey = GlobalKey(); // Define the key here

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
      duration: const Duration(milliseconds: 50),
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
      _sheetKey.currentWidget as DraggableScrollableSheet; // Update the getter

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: LayoutBuilder(builder: (context, constraints) {
        return DraggableScrollableSheet(
          key: _sheetKey, // Use the key here
          initialChildSize: 0.6,
          maxChildSize: 0.95,
          minChildSize: 0,
          expand: true,
          snap: true,
          snapSizes: [40 / constraints.maxHeight, 0.5],
          controller: _controller,
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  topButtonIndicator(),
                  SliverToBoxAdapter(
                    child: widget.child,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  hide();
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    widget.onClose();
                                  });
                                },
                                style: const ButtonStyle(
                                  animationDuration: Duration(seconds: 1),
                                  splashFactory: InkRipple.splashFactory,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearFilter,
                                style: const ButtonStyle(
                                  animationDuration: Duration(seconds: 1),
                                ),
                                child: const Text('Clear Filters',
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          filterOption(
                            'Age',
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Min Age: ${_minAge?.toString() ?? 'Any'}'),
                                    Text(
                                        'Max Age: ${_maxAge?.toString() ?? 'Any'}'),
                                  ],
                                ),
                                RangeSlider(
                                        activeColor: Colors.blueAccent,
                                        values: RangeValues(
                                          (_minAge?.toDouble() ?? 0)
                                              .clamp(0, 150),
                                          (_maxAge?.toDouble() ?? 150)
                                              .clamp(0, 150),
                                        ),
                                        min: 0,
                                        max: 150,
                                        divisions: 150,
                                        labels: RangeLabels(
                                          _minAge?.toString() ?? '0',
                                          _maxAge?.toString() ?? '150',
                                        ),
                                        onChanged: (RangeValues values) {
                                          if (values.start < 0 ||
                                              values.end > 150) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Age must be between 0 and 150',
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                            );
                                          } else {
                                            setState(() {
                                              _minAge = values.start.toInt();
                                              _maxAge = values.end.toInt();
                                              _minAgeController.text =
                                                  _minAge.toString();
                                              _maxAgeController.text =
                                                  _maxAge.toString();
                                              _applyFilter();
                                            });
                                          }
                                        },
                                      ),
                                    
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              filterOption(
                                'Weight',
                                DropdownButton<String>(
                                  value: _weight,
                                  hint: const Text('Any'),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _weight = newValue;
                                      _applyFilter();
                                    });
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
                                    'fat',
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              filterOption(
                                'Gender',
                                IconButton(
                                  icon: Icon(
                                    _gender == 'male'
                                        ? Icons.male
                                        : _gender == 'female'
                                            ? Icons.female
                                            : Icons.person_outline,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _gender = _gender == 'male'
                                          ? 'female'
                                          : _gender == 'female'
                                              ? null
                                              : 'male';
                                      _applyFilter();
                                    });
                                  },
                                ),
                              ),
                              filterOption(
                                'Skin Color',
                                DropdownButton<String>(
                                  value: _skinColor,
                                  hint: const Text('Any'),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _skinColor = newValue;
                                      _applyFilter();
                                    });
                                  },
                                  items: <String>[
                                    'fair',
                                    'black',
                                    'white',
                                    'teyim',
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget filterOption(String title, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          widget,
        ],
      ),
    );
  }

  Widget topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
          child: GestureDetector(
            onTap: () {
              widget.onClose();
            },
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
