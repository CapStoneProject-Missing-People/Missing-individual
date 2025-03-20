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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: isLoggedIn
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.pushNamed(context, '/manageProfile'); // Navigate to profile
                      },
                      child: Row(
                        children: [
                          // User Avatar
                          // User Avatar with Animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade700
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 30,
                              child: Text(
                                user.name
                                    .substring(0, 1)
                                    .toUpperCase(), // First letter of name
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // User Name
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.pushNamed(context, '/login'); // Navigate to login
                      },
                      child: const Row(
                        children: [
                          // Guest Avatar
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Icon(
                              Icons.person,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Login Text
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    route: '/manageProfile',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.group,
                    title: 'Matched People',
                    route: '/matchedPeople',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.post_add_outlined,
                    title: 'My Posts',
                    route: '/missingPersonPosted',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    route: '/feedBack',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.message,
                    title: 'Messages',
                    route: '/chatList',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    route: '/settings',
                  ),
                  const Divider(
                    color: Colors.white24,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  if (isLoggedIn) // Show the sign-out button only if the user is logged in
                    _buildDrawerItem(
                      context,
                      icon: Icons.exit_to_app_outlined,
                      title: 'Sign Out',
                      onTap: () => signOutUser(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(
          icon,
          size: 28,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          if (route != null) {
            Navigator.pushNamed(context, route); // Navigate to the specified route
          } else if (onTap != null) {
            onTap(); // Execute custom onTap function
          }
        },
      ),
    );
  }
}
