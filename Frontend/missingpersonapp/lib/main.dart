import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:missingpersonapp/common/services/fcm-service.dart';
import 'package:missingpersonapp/features/Notifications/provider/missingcase-provider.dart';
import 'package:missingpersonapp/features/Notifications/screens/display_notification.dart';
import 'package:missingpersonapp/features/PostAdd/screens/addpost.dart';
import 'package:missingpersonapp/features/Profile/screens/profile_page.dart';
import 'package:missingpersonapp/features/authentication/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/login_page.dart';
import 'package:missingpersonapp/features/authentication/screens/missing_person_page.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/feedback/screens/feedback.dart';
import 'package:missingpersonapp/features/home/provider/allMissingperson.dart';
import 'package:missingpersonapp/features/home/screens/home_page.dart';
import 'package:missingpersonapp/features/matchedCase/provider/matched_case_provider.dart';
import 'package:missingpersonapp/features/matchedCase/screens/matched_case.dart';
import 'package:missingpersonapp/firebase_options.dart';
import 'package:provider/provider.dart';

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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AllMissingPeopleProvider()),
      ChangeNotifierProvider(create: (_) => CaseProvider()),
      ChangeNotifierProvider(create: (_) => MatchedCaseProvider()),
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
      home: Provider.of<UserProvider>(context).user.token.isEmpty
          ? LoginPage()
          : const HomePage(),
      routes: {
        '/manageProfile': (context) => const ManageProfilePage(),
        '/addPost': (context) => const MissingPersonAddPage(),
        '/feedBack': (context) => const FeedbackPage(),
        '/matchedPeople': (context) => const MatchedCases(),
        '/notification': (context) => const NotificationPage(),
        '/missingPersonPosted': (context) => MissingPersonPage(),
      },
    );
  }
}
