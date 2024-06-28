import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/existing_case_screen.dart';
import 'package:missingpersonapp/features/matchedCase/screens/imageMatch/face_match.dart';
import 'package:missingpersonapp/features/matchedCase/screens/over_all_match.dart';

class MatchedCases extends StatefulWidget {
  const MatchedCases({super.key});

  @override
  State<MatchedCases> createState() => _MatchedCasesState();
}

class _MatchedCasesState extends State<MatchedCases> {
  // State variable to track the current page index
  int _selectedIndex = 0;

  // List of pages to switch between
  final List<Widget> _pages = [
    ExistingCasesScreen(),
    const MissingPersonImageMatch(),
    const OverAllMatch(),
  ];

  // Function to handle navigation bar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Description Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Face Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.merge_outlined),
            label: 'Merged',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
