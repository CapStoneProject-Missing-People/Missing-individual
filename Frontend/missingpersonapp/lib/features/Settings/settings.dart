import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: userProvider.notificationsEnabled,
                  onChanged: (bool value) {
                    userProvider.toggleNotifications(value);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
