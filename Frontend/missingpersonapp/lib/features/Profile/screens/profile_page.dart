import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/Profile/screens/profile_detail_item.dart';
import 'package:missingpersonapp/features/authentication/models/user.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:provider/provider.dart';

class ManageProfilePage extends StatefulWidget {
  const ManageProfilePage({super.key});

  @override
  _ManageProfilePageState createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  late User _userData;

  @override
  void initState() {
    super.initState();
    _userData = Provider.of<UserProvider>(context, listen: false).user;
  }

  @override
  Widget build(BuildContext context) {
    _userData = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profile'),
      ),
      body: _userData.name.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.blue[50],
                    surfaceTintColor: Colors.yellowAccent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ProfileDetailItem(label: 'Name', value: _userData.name),
                          ProfileDetailItem(label: 'Email', value: _userData.email),
                          ProfileDetailItem(label: 'Phone Number', value: _userData.phoneNo),
                        ],
                      ),
                    ),
                  ),
                ),
                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextButton(
                    onPressed: () {
                      _showEditDialog();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
                
                // Action Buttons Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Delete Account Button
                      ElevatedButton(
                        onPressed: () {
                          _confirmAndDeleteAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text('Delete Account'),
                      ),
                      // Deactivate Button
                      ElevatedButton(
                        onPressed: () {
                          // Handle deactivation
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange[400],
                        ),
                        child: const Text('Deactivate'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProfileDialog(user: _userData);
      },
    );
  }

  void _confirmAndDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the confirmation dialog
                bool success = await Provider.of<UserProvider>(context, listen: false).deleteUserProfile();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully')),
                  );
                  // Log out the user and navigate to the appropriate screen
                  signOutUser(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete account')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }
}

class EditProfileDialog extends StatefulWidget {
  final User user;

  const EditProfileDialog({required this.user});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNoController;
  late User _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.user;
    _nameController = TextEditingController(text: _userData.name);
    _emailController = TextEditingController(text: _userData.email);
    _phoneNoController = TextEditingController(text: _userData.phoneNo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneNoController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            _userData = _userData.copyWith(
              name: _nameController.text,
              email: _emailController.text,
              phoneNo: _phoneNoController.text,
            );
            String userJson = _userData.toJson();
            bool success = await Provider.of<UserProvider>(context, listen: false)
                .updateUserProfile(userJson);
            if (success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update profile')),
              );
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    super.dispose();
  }
}
