import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/missingPerson/models/missing_person_model.dart';
import 'package:missingpersonapp/features/missingPerson/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/missingPerson/screens/missing_person_card.dart';
import 'package:missingpersonapp/features/authentication/utils/utils.dart';
import 'package:provider/provider.dart';

class MissingPersonPage extends StatefulWidget {
  const MissingPersonPage({super.key});

  @override
  State<MissingPersonPage> createState() => _MissingPersonPageState();
}

class _MissingPersonPageState extends State<MissingPersonPage> {
  final int _itemsPerPage = 14;
  int _currentPage = 1;
  final List<MissingPersonSpecific> _displayedMissingPersons = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMissingPersons();
  }

  Future<void> _fetchMissingPersons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await Provider.of<MissingPersonProvider>(context, listen: false)
          .fetchMissingPersons(context);
      _loadPageItems();
    } catch (e) {
      print('Error fetching missing persons: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      showToast(context, e.toString(), Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadPageItems() {
    final provider = Provider.of<MissingPersonProvider>(context, listen: false);
    setState(() {
      _displayedMissingPersons.clear();
      final int startIndex = (_currentPage - 1) * _itemsPerPage;
      final int endIndex = startIndex + _itemsPerPage;
      _displayedMissingPersons.addAll(
        provider.missingPersons.sublist(
          startIndex,
          endIndex > provider.missingPersons.length
              ? provider.missingPersons.length
              : endIndex,
        ),
      );
    });
  }

  void _goToNextPage() {
    final provider = Provider.of<MissingPersonProvider>(context, listen: false);
    if (_currentPage * _itemsPerPage < provider.missingPersons.length) {
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900.withOpacity(0.8),
        title: const Text(
          'My Posts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<MissingPersonProvider>(
          builder: (context, provider, child) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            if (_errorMessage.isNotEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchMissingPersons,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.missingPersons.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'No posts by user',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchMissingPersons,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _displayedMissingPersons.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 300,
                      ),
                      itemBuilder: (context, index) {
                        final missingPerson = _displayedMissingPersons[index];
                        return MissingPersonCard(missingPerson: missingPerson);
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color:
                                _currentPage > 1 ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        'Page $_currentPage',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: _currentPage * _itemsPerPage <
                                provider.missingPersons.length
                            ? _goToNextPage
                            : null,
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: _currentPage * _itemsPerPage <
                                    provider.missingPersons.length
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}