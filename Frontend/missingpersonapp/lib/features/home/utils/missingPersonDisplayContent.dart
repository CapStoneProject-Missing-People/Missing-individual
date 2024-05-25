import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/models/missing_person.dart';
import 'package:missingpersonapp/features/home/data/missing_person_fetch.dart';
import 'package:missingpersonapp/features/home/utils/missingPeopleDisplayCard.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

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

  Future<void> _fetchAllMissingPeople() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<MissingPerson> missingPeople = await fetchMissingPeople();
      setState(() {
        _allMissingPeople.addAll(missingPeople);
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
      final int startIndex = (_currentPage - 1) * _itemsPerPage;
      final int endIndex = startIndex + _itemsPerPage;
      _displayedMissingPeople.addAll(
        _allMissingPeople.sublist(
          startIndex,
          endIndex > _allMissingPeople.length
              ? _allMissingPeople.length
              : endIndex,
        ),
      );
      _isLoading = false;
    });
  }

  void _goToNextPage() {
    if (_currentPage * _itemsPerPage < _allMissingPeople.length) {
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
                onPressed:
                    _currentPage * _itemsPerPage < _allMissingPeople.length
                        ? _goToNextPage
                        : null,
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: _currentPage * _itemsPerPage < _allMissingPeople.length ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
