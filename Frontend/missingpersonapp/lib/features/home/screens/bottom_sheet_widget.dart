import 'package:flutter/material.dart';

class MyDraggableSheet extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Function(Map<String, dynamic>) onFilterChanged;

  const MyDraggableSheet({
    super.key,
    required this.child,
    required this.visible,
    required this.onFilterChanged,
  });

  @override
  State<MyDraggableSheet> createState() => _MyDraggableSheetState();
}

class _MyDraggableSheetState extends State<MyDraggableSheet> {
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();

  int? _age;
  String? _weight;
  String? _gender;
  String? _skinColor;

  @override
  void initState() {
    super.initState();
    controller.addListener(onChanged);
  }

  void onChanged() {
    final currentSize = controller.size;
    if (currentSize <= 0.05) collapse();
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);

  void anchor() => animateSheet(getSheet.snapSizes!.last);

  void expand() => animateSheet(getSheet.maxChildSize);

  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double size) {
    controller.animateTo(
      size,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  void _applyFilter() {
    widget.onFilterChanged({
      'age': _age,
      'weight': _weight,
      'gender': _gender,
      'skinColor': _skinColor,
    });
  }

  void _clearFilter() {
    setState(() {
      _age = null;
      _weight = null;
      _gender = null;
      _skinColor = null;
    });
    _applyFilter();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  DraggableScrollableSheet get getSheet =>
      (sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: LayoutBuilder(builder: (context, constraints) {
        return DraggableScrollableSheet(
          key: sheet,
          initialChildSize: 0.05,
          maxChildSize: 0.95,
          minChildSize: 0,
          expand: true,
          snap: true,
          snapSizes: [
            40 / constraints.maxHeight,
            0.5,
          ],
          controller: controller,
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
                          filterOption(
                            'Age',
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_downward),
                                  onPressed: () {
                                    setState(() {
                                      if (_age != null && _age! > 0) _age = _age! - 1;
                                      _applyFilter();
                                    });
                                  },
                                ),
                                Text(_age?.toString() ?? 'Any'),
                                IconButton(
                                  icon: const Icon(Icons.arrow_upward),
                                  onPressed: () {
                                    setState(() {
                                      if (_age != null) {
                                        _age = _age! + 1;
                                      } else {
                                        _age = 1;
                                      }
                                      _applyFilter();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          filterOption(
                            'Weight',
                            DropdownButton<String>(
                              value: _weight,
                              hint: Text('Any'),
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
                              ].map<DropdownMenuItem<String>>((String value) {
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
                              hint: Text('Any'),
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
                                'tseyim',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _clearFilter,
                            child: const Text('Clear Filters'),
                          ),
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

  Widget filterOption(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18)),
          control,
        ],
      ),
    );
  }

  SliverToBoxAdapter topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Center(
                child: Wrap(
                  children: <Widget>[
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
