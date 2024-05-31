import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/home/data/missing_person_fetch.dart';
import 'package:missingpersonapp/features/home/utils/missingPeopleDisplayCard.dart';

class HomePageContent extends StatefulWidget {
  final String searchText;
  final ValueChanged<List<MissingPerson>> onMissingPeopleFetched;
  final Map<String, dynamic> filters; // Added filters

  const HomePageContent({
    Key? key,
    required this.searchText,
    required this.onMissingPeopleFetched,
    required this.filters, // Added filters
  }) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final List<MissingPerson> _allMissingPeople = [];
  final List<Map<String, dynamic>> _displayedMissingPeople = [];
  int _currentPage = 1;
  final int _itemsPerPage = 14;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllMissingPeople();
  }

  @override
  void didUpdateWidget(covariant HomePageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchText != widget.searchText ||
        oldWidget.filters != widget.filters) {
      _loadPageItems();
    }
  }

  Future<void> _fetchAllMissingPeople() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<MissingPerson> missingPeople = await fetchMissingPeople();
      setState(() {
        _allMissingPeople.addAll(missingPeople);
        widget.onMissingPeopleFetched(_allMissingPeople);
        _loadPageItems();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _loadPageItems() {
    setState(() {
      _displayedMissingPeople.clear();
      final List<Map<String, dynamic>> filteredPeople = _applySearch();
      final int startIndex = (_currentPage - 1) * _itemsPerPage;
      final int endIndex = startIndex + _itemsPerPage;
      _displayedMissingPeople.addAll(
        filteredPeople.sublist(
          startIndex,
          endIndex > filteredPeople.length ? filteredPeople.length : endIndex,
        ),
      );
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _applySearch() {
    final searchText = widget.searchText.toLowerCase();
    final filters = widget.filters;

    return _allMissingPeople
        .map((person) {
          final name = person.name;
          final skinColor = person.skin_color;
          final age = person.age.toString();

          final lowerCaseName = name.toLowerCase();
          final lowerCaseSkinColor = skinColor.toLowerCase();
          final lowerCaseAge = age.toLowerCase();

          // Check search text
          final searchTextMatch = searchText.isEmpty ||
              lowerCaseName.contains(searchText) ||
              lowerCaseSkinColor.contains(searchText) ||
              lowerCaseAge.contains(searchText);

          // Check filters
          final minAge = filters['minAge'];
          final maxAge = filters['maxAge'];
          final ageMatch = (minAge == null || person.age >= minAge) &&
        (maxAge == null || person.age <= maxAge);

          final skinColorMatch =
              filters['skinColor'] == null || filters['skinColor'] == skinColor;

          if (searchTextMatch && ageMatch && skinColorMatch) {
            final textSpansName = _highlightOccurrences(name, searchText);
            final textSpansSkinColor =
                _highlightOccurrences(skinColor, searchText);
            final textSpansAge = _highlightOccurrences(age, searchText);
            return {
              'person': person,
              'textSpansName': textSpansName,
              'textSpansSkinColor': textSpansSkinColor,
              'textSpansAge': textSpansAge,
            };
          }
          return null;
        })
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }

  List<TextSpan> _highlightOccurrences(String source, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: source)];
    }

    final matches = <Match>[];
    for (int i = 0; i <= source.length - query.length; i++) {
      if (source.substring(i, i + query.length).toLowerCase() == query) {
        matches.add(Match(i, i + query.length));
      }
    }

    if (matches.isEmpty) {
      return [TextSpan(text: source)];
    }

    final List<TextSpan> spans = [];
    int start = 0;

    for (var match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: source.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: const TextStyle(
          color: Colors.blue,
        ),
      ));
      start = match.end;
    }

    if (start < source.length) {
      spans.add(TextSpan(text: source.substring(start)));
    }

    return spans;
  }

  void _goToNextPage() {
    if (_currentPage * _itemsPerPage < _applySearch().length) {
      setState(() {
        _currentPage++;
        _loadPageItems();
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _loadPageItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _displayedMissingPeople.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 410,
                  ),
                  itemBuilder: (context, index) {
                    final item = _displayedMissingPeople[index];
                    return MissingPeopleDisplay(
                      missingPerson: item['person'],
                      highlightedName: item['textSpansName'],
                      highlightedSkinColor: item['textSpansSkinColor'],
                      highlightedAge: item['textSpansAge'],
                    );
                  },
                ),
        ),
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: _currentPage > 1 ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              Text('Page $_currentPage'),
              TextButton(
                onPressed: _currentPage * _itemsPerPage < _applySearch().length
                    ? _goToNextPage
                    : null,
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: _currentPage * _itemsPerPage < _applySearch().length
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class Match {
  final int start;
  final int end;

  Match(this.start, this.end);
}
