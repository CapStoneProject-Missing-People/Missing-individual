import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    bool isLoggedIn = user.token.isNotEmpty;

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white12,
              ),
              child: isLoggedIn
                  ? Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent, // Outline color
                              width: 1.0, // Outline width
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: 24,
                            child: Text(
                              user.name.substring(0,
                                  1), // Display the first letter of the user's name
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width:
                                16), // Add some spacing between the avatar and the name
                        Text(
                          user.name, // Display the logged-in user's name
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent, // Outline color
                              width: 1.0, // Outline width
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            radius: 24,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close the drawer
                            Navigator.pushNamed(context,
                                '/login'); // Navigate to the login page
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          CustomListTile(
            icon: Icons.person_outline_sharp,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context,
                  '/manageProfile'); // Navigate to the manage profile page
            },
          ),
          // CustomListTile(
          //   icon: Icons.article_outlined,
          //   title: 'My Posts',
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer
          //     Navigator.pushNamed(context,
          //         '/missingPost'); // Navigate to the manage profile page
          //   },
          // ),
          CustomListTile(
            icon: Icons.group,
            title: 'Matched People',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context,
                  '/matchedPeople'); // Navigate to the manage profile page
            },
          ),
          CustomListTile(
            icon: Icons.post_add_outlined,
            title: 'My Posts',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context,
                  '/missingPersonPosted'); // Navigate to the manage profile page
            },
          ),
          
          CustomListTile(
            icon: Icons.feedback_outlined,
            title: 'FeedBack',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(
                  context, '/feedBack'); // Navigate to the manage profile page
            },
          ),
          CustomListTile(
            icon: Icons.message,
            title: 'Messages',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context,
                  '/chatList'); // Navigate to the chat list screen
            },
          ),
          CustomListTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(
                  context, '/settings'); // Navigate to the manage profile page
            },
          ),
          const Spacer(), // Push the sign-out tile to the bottom
          if (isLoggedIn) // Show the sign-out button only if the user is logged in
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: GestureDetector(
                onTap: () => signOutUser(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16), // Add padding to the ListTile
      leading: Icon(icon, size: 24, color: Colors.blue),
      title: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      onTap: onTap,
    );
  }
}
