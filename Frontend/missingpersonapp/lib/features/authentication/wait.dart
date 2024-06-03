import 'package:flutter/material.dart';
import 'package:missingpersonapp/features/authentication/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/login_page.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/home/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProxyProvider<UserProvider, MissingPersonProvider>(
        create: (context) {
          final user = Provider.of<UserProvider>(context, listen: false).user;
          return MissingPersonProvider(user);
        },
        update: (context, userProvider, missingPersonProvider) {
          return MissingPersonProvider(userProvider.user);
        },
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Node Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider.of<UserProvider>(context).user.token.isEmpty
          ? LoginPage()
          : const HomePage(),
    );
  }
}
