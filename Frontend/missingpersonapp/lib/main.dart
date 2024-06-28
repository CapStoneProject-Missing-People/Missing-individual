import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:missingpersonapp/common/services/fcm-service.dart';
import 'package:missingpersonapp/common/utils/add_guard.dart';
import 'package:missingpersonapp/features/Notifications/provider/missingcase-provider.dart';
import 'package:missingpersonapp/features/Notifications/provider/notification_provider.dart';
import 'package:missingpersonapp/features/Notifications/screens/display_notification.dart';
import 'package:missingpersonapp/features/PostAdd/screens/addpost.dart';
import 'package:missingpersonapp/features/Profile/screens/profile_page.dart';
import 'package:missingpersonapp/features/Settings/settings.dart';
import 'package:missingpersonapp/features/authentication/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/login_page.dart';
import 'package:missingpersonapp/features/authentication/screens/missing_person_page.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/chat/providers/chat_provider.dart';
import 'package:missingpersonapp/features/chat/screens/chat_list_screen.dart';
import 'package:missingpersonapp/features/compare/screens/compare.dart';
import 'package:missingpersonapp/features/feedback/provider/feedback_provider.dart';
import 'package:missingpersonapp/features/feedback/screens/feedback.dart';
import 'package:missingpersonapp/features/home/provider/allMissingperson.dart';
import 'package:missingpersonapp/features/home/provider/matchcase.dart';
import 'package:missingpersonapp/features/home/screens/home_page.dart';
import 'package:missingpersonapp/features/matchedCase/provider/desc_match_provider.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';
import 'package:missingpersonapp/features/matchedCase/screens/matched_case.dart';
import 'package:missingpersonapp/features/matchedCase/service/missing_person_match_service.dart';
import 'package:missingpersonapp/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  // Handle the message data here as needed
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(MessageAdapter());
  
  // Open Hive boxes
  await Hive.openBox<Message>('messages');
  await Hive.openBox('authBox');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AllMissingPeopleProvider()),
      ChangeNotifierProvider(create: (_) => CaseProvider()),
      ChangeNotifierProvider(create: (_) => MatchedCaseProvider()),
      ChangeNotifierProvider(create: (_) => CaseMatchedProvider()),
      ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ChangeNotifierProvider(create: (_) => DescriptionMatchProvider(apiService: DescriptionMatchService())),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),

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
  final FcmService fcmService = FcmService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
    fcmService.initialize(context);

    // Load user preferences
    Provider.of<UserProvider>(context, listen: false).loadUserPreferences();
  }
Future<Widget> _getInitialScreen(BuildContext context) async {
  try {
    // Check network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("No network connection");
    }

    // Get shared preferences and user data concurrently
    final prefsFuture = SharedPreferences.getInstance();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userFuture = authService.getUserData(context);

    // Await both futures concurrently
    final results = await Future.wait([
      prefsFuture,
      userFuture,
    ]);

    final prefs = results[0] as SharedPreferences;
    final user = userProvider.user;
    String? token = prefs.getString('authorization');
    print("Token is: $token");

    if (token != null && token.isNotEmpty) {
      // Check if the token is still valid
      bool isValid = await AuthService().isTokenValid(token).timeout(
            const Duration(seconds: 65), // Set a timeout for the token validation
            onTimeout: () {
              throw TimeoutException("Token validation timed out");
            },
          );

      if (isValid) {
        await AuthService().getUserData(context);
        print("User name: ${user.name}");
        print("Email: ${user.email}");
        return const HomePage();
      } else {
        print("Token is not valid");
      }
    } else {
      print("No token found");
    }

    // Navigate to HomePage regardless of the token status
    return const HomePage();
  } catch (e) {
    print("Error occurred: $e"); // Log the error for debugging
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Could not connect to the network.',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MissingPerson',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.green,
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.grey,
        ),
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/manageProfile': (context) =>
            AuthGuard(child: const ManageProfilePage()),
        '/addPost': (context) => AuthGuard(child: const MissingPersonAddPage()),
        '/feedBack': (context) => AuthGuard(child: const FeedbackPage()),
        '/matchedPeople': (context) => AuthGuard(child: const MatchedCases()),
        '/notification': (context) =>
            AuthGuard(child: const NotificationPage()),
        '/compare': (context) => ComparePersonPage(),
        '/missingPersonPosted': (context) =>
            AuthGuard(child: MissingPersonPage()),
          '/settings': (context) => SettingsPage(),
          '/chatList': (context) => AuthGuard(child: ChatListScreen(
          userId: Provider.of<UserProvider>(context, listen: false).user.id,
        )),
      },
    );
  }
}
