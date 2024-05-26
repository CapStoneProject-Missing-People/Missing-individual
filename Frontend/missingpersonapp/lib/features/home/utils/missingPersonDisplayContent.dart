import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/home/data/missing_person_fetch.dart';
import 'package:missingpersonapp/features/home/utils/missingPeopleDisplayCard.dart';

class HomePageContent extends StatefulWidget {
  final String searchText;
  final ValueChanged<List<MissingPerson>> onMissingPeopleFetched;

  const HomePageContent({
    Key? key,
    required this.searchText,
    required this.onMissingPeopleFetched,
  }) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final List<MissingPerson> _allMissingPeople = [];
  final List<MissingPerson> _displayedMissingPeople = [];
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
    if (oldWidget.searchText != widget.searchText) {
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
      final List<MissingPerson> filteredPeople = _applySearch();
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

  List<MissingPerson> _applySearch() {
    return _allMissingPeople.where((person) {
      final searchText = widget.searchText.toLowerCase();
      return widget.searchText.isEmpty ||
          person.name.toLowerCase().contains(searchText) ||
          person.age.toString().contains(searchText);
    }).toList();
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
                    return MissingPeopleDisplay(
                        missingPerson: _displayedMissingPeople[index]);
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
