import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/common/utils/add_guard.dart';
import 'package:missingpersonapp/features/Notifications/screens/display_notification.dart';
import 'package:missingpersonapp/features/PostAdd/screens/addpost.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/chat/screens/chat_list_screen.dart';
import 'package:missingpersonapp/features/compare/screens/compare.dart';
import 'package:missingpersonapp/features/home/screens/bottom_sheet_widget.dart';
import 'package:missingpersonapp/features/home/screens/check_face.dart';
import 'package:missingpersonapp/common/screens/profile_drawer.dart';
import 'package:missingpersonapp/features/home/screens/missingPersonDisplayContent.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/Notifications/provider/notification_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  Future<void> signOutUser(BuildContext context) async {
    final authService = AuthService();
    final tokensBeforeLogout = await authService.getTokens();
    print('Tokens before signing out:');
    print('Access Token: ${tokensBeforeLogout['accessToken']}');
    print('Refresh Token: ${tokensBeforeLogout['refreshToken']}');
    print('Email: ${tokensBeforeLogout['email']}');
    print('isLoggedIn: ${tokensBeforeLogout['isLoggedIn']}');
    print('lastLogin: ${tokensBeforeLogout['lastLogin']}');

    authService.signOut(context);

    // Log tokens after signing out
    final tokensAfterLogout = await authService.getTokens();
    print('Tokens after signing out:');
    print('Access Token: ${tokensAfterLogout['accessToken']}');
    print('Refresh Token: ${tokensAfterLogout['refreshToken']}');
    print('Email: ${tokensAfterLogout['email']}');
    print('isLoggedIn: ${tokensAfterLogout['isLoggedIn']}');
    print('lastLogin: ${tokensAfterLogout['lastLogin']}');
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  String _searchText = '';
  bool _isFilterVisible = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _filters = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateSearchText(String text) {
    setState(() {
      _searchText = text;
    });
  }

  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _onFilterChanged(Map<String, dynamic> filterData) {
    setState(() {
      _filters = filterData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent, // Set background to transparent
        elevation: 0, // Remove shadow
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 180, sigmaY: 80), // Blur effect
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        title: _selectedIndex == 0
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        debugPrint("Search");
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        onChanged: _updateSearchText,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _uploadPhoto(context);
                      },
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                _getTitleForIndex(_selectedIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _toggleFilterVisibility,
                  icon: const Icon(Icons.filter_list_outlined,
                      color: Colors.white),
                ),
              ]
            : [],
      ),
      drawer: const ProfileDrawer(),
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
            _selectedIndex == 0
                ? HomePageContent(
                    searchText: _searchText,
                    filters: _filters,
                  )
                : _selectedIndex == 1
                    ? const AuthGuard(child: MissingPersonAddPage())
                    : _selectedIndex == 2
                        ? const ComparePersonPage()
                        : _selectedIndex == 3
                            ? AuthGuard(
                                child: ChatListScreen(
                                userId: Provider.of<UserProvider>(context,
                                        listen: false)
                                    .user
                                    .id,
                              ))
                            : const NotificationPage(),
            MyDraggableSheet(
              visible: _isFilterVisible,
              onFilterChanged: _onFilterChanged,
              onClose: () => setState(() => _isFilterVisible = false),
              child: const Center(
                child: Text(
                  'Filter Options',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return Container(
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
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal),
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    color: _selectedIndex == 0 ? Colors.blue : Colors.white70,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add_box_outlined,
                    color: _selectedIndex == 1 ? Colors.blue : Colors.white70,
                  ),
                  label: 'Add Post',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.compare_arrows_outlined,
                    color: _selectedIndex == 2 ? Colors.blue : Colors.white70,
                  ),
                  label: 'Compare',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.message_outlined,
                    color: _selectedIndex == 3 ? Colors.blue : Colors.white70,
                  ),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        color:
                            _selectedIndex == 4 ? Colors.blue : Colors.white70,
                      ),
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '${notificationProvider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Notification',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) {
                _onItemTapped(index);
                if (index == 2) {
                  notificationProvider.markAllAsRead();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _uploadPhoto(BuildContext context) async {
    final ImagePicker imagePicker = ImagePicker();

    final ImageSource? imageSource = await showDialog<ImageSource?>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Select Image Source',
          style: TextStyle(color: Colors.white),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: Colors.blue, size: 32),
                      SizedBox(width: 8),
                      Text('Camera',
                          style: TextStyle(color: Colors.blue, fontSize: 20)),
                    ],
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Row(
                    children: [
                      Icon(Icons.photo_camera_back_outlined,
                          color: Colors.blue, size: 32),
                      SizedBox(width: 8),
                      Text('Gallery',
                          style: TextStyle(color: Colors.blue, fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (imageSource != null) {
      final XFile? image = await imagePicker.pickImage(source: imageSource);
      if (image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckFace(imagePath: image.path),
          ),
        );
      }
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Add Post';
      case 2:
        return 'Compare';
      case 3:
        return 'Messages';
      case 4:
        return 'Notification';
      default:
        return 'Notification';
    }
  }
}
