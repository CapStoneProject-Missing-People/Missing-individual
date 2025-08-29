import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          child: Column(
            children: [
              // Glassmorphic AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notifications Setting
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white.withOpacity(0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SwitchListTile(
                                title: const Text(
                                  'Enable Notifications',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: const Text(
                                  'Receive alerts for new matches',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                value: userProvider.notificationsEnabled,
                                activeColor: Colors.blue,
                                onChanged: (bool value) {
                                  userProvider.toggleNotifications(value);
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dark Mode Setting (Placeholder)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'Dark Mode',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 2,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: const Text(
                              'Toggle dark theme',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            value: false, // Placeholder
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              // Placeholder for dark mode toggle
                              // Provider.of<UserProvider>(context, listen: false).toggleDarkMode(value);
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Logout Option
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              // Placeholder for logout
                              // Provider.of<UserProvider>(context, listen: false).logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logout functionality not implemented')),
                              );
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: const Text(
                                'Sign out of your account',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.exit_to_app,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}