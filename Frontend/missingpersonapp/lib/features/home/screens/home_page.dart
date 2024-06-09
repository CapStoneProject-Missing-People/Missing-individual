// home_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/features/Notifications/screens/display_notification.dart';
import 'package:missingpersonapp/features/PostAdd/screens/addpost.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/compare/screens/compare.dart';
import 'package:missingpersonapp/features/home/screens/bottom_sheet_widget.dart';
import 'package:missingpersonapp/features/home/screens/check_face.dart';
import 'package:missingpersonapp/common/screens/profile_drawer.dart';
import 'package:missingpersonapp/features/home/screens/missingPersonDisplayContent.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/Notifications/provider/notification_provider.dart'; // Add this line

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
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
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: _selectedIndex == 0
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        debugPrint("Search");
                      },
                      icon: const Icon(Icons.search, color: Colors.black38),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.grey[800]),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.black38),
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
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                _getTitleForIndex(_selectedIndex),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _toggleFilterVisibility,
                  icon: const Icon(Icons.filter_list_outlined),
                ),
              ]
            : [],
      ),
      drawer: const ProfileDrawer(),
      body: Stack(
        children: [
        _selectedIndex == 0
    ? HomePageContent(
        searchText: _searchText,
        filters: _filters,
      )
    : _selectedIndex == 1
        ? const MissingPersonAddPage()
        : _selectedIndex == 2
            ? const NotificationPage()
            : const ComparePersonPage(),
          MyDraggableSheet(
            visible: _isFilterVisible,
            onFilterChanged: _onFilterChanged,
            onClose: () => setState(() => _isFilterVisible = false),
            child: const Center(
              child: Text(
                'Filter Options',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label: 'Add Post',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none_outlined),
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
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            onTap: (index) {
              _onItemTapped(index);
              if (index == 2) {
                notificationProvider.markAllAsRead();
              }
            },
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
        title: const Text('Select Image Source'),
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
        return 'Notification';
      case 3:
        return 'Compare Feature';
      default:
        return 'Missing Person App';
    }
  }
}
