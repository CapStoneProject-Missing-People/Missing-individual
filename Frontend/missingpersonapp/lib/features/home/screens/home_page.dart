import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:missingpersonapp/features/Notifications/screens/display_notification.dart';
import 'package:missingpersonapp/features/PostAdd/screens/addpost.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/home/services/check_face.dart';
import 'package:missingpersonapp/features/home/screens/profile_drawer.dart';
import 'package:missingpersonapp/features/home/utils/missingPersonDisplayContent.dart';

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

 static final List<Widget> _pages = <Widget>[
  const HomePageContent(),
  const MissingPersonAddPage(),
  const NotificationPage(),
 ];

 void _onItemTapped(int index) {
  setState(() {
   _selectedIndex = index;
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
            style: TextStyle(color: Colors.grey[800]),
            decoration: const InputDecoration(
             hintText: 'Search',
             hintStyle: TextStyle(color: Colors.black38),
             border: InputBorder.none,
            ),
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
      : Text(_getTitleForIndex(_selectedIndex), style: const TextStyle(fontWeight: FontWeight.w700)),
    actions: _selectedIndex == 0
      ? [
        IconButton(
         onPressed: () {
          // filter
         },
         icon: const Icon(Icons.filter_list_outlined),
        ),
       ]
      : [],
   ),
   drawer: const ProfileDrawer(),
   body: _pages[_selectedIndex],
   bottomNavigationBar: BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
     BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
     ),
     BottomNavigationBarItem(
      icon: Icon(Icons.add_box_outlined),
      label: 'Add Post',
     ),
     BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none_outlined),
      label: 'Notification',
     ),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.black,
    onTap: _onItemTapped,
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
           Icon(Icons.camera_alt_outlined, color: Colors.blue, size: 32),
           SizedBox(width: 8),
           Text('Camera', style: TextStyle(color: Colors.blue, fontSize: 20)),
          ],
         ),
        ),
        SimpleDialogOption(
         onPressed: () => Navigator.pop(context, ImageSource.gallery),
         child: const Row(
          children: [
           Icon(Icons.photo_camera_back_outlined, color: Colors.blue, size: 32),
           SizedBox(width: 8),
           Text('Gallery', style: TextStyle(color: Colors.blue, fontSize: 20)),
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
    return 'Profile';
   default:
    return 'Missing Person App';
  }
 }
}