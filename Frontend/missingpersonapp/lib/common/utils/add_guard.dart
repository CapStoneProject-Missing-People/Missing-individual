import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:provider/provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user.token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          showDialog(
            context: context,
            barrierDismissible:
                false, // Prevent dismissing the dialog by tapping outside
            builder: (context) => WillPopScope(
              onWillPop: () async {
                // Navigate to home page when back button is pressed
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (Route<dynamic> route) => false,
                );
                return false; // Prevent the default back button behavior
              },
              child: AlertDialog(
                title: Text('Login Required'),
                content: Text('You need to be logged in to access this page.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red, // Text color
                    ),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', // Change this to your login route
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          );
        }
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return child;
    }
  }
}