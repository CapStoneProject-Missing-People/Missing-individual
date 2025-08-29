import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/screens/glass_morphic_button.dart';
import 'package:missingpersonapp/features/matchedCase/screens/DescriptionMatch/existing_case_screen.dart';
import 'package:missingpersonapp/features/matchedCase/screens/imageMatch/face_match.dart';
import 'package:missingpersonapp/features/matchedCase/screens/over_all_match.dart';

class MatchedCases extends StatefulWidget {
  const MatchedCases({super.key});

  @override
  State<MatchedCases> createState() => _MatchedCasesState();
}

class _MatchedCasesState extends State<MatchedCases> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExistingCasesScreen(),
    const MissingPersonImageMatch(),
    const OverAllMatch(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        child: SafeArea(
          child: Stack(
            children: [
              _pages[_selectedIndex],
              Positioned(
                top: 10,
                left: 10,
                child: GlassmorphismButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          type: BottomNavigationBarType.fixed,
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
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
