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
import 'package:missingpersonapp/features/chat/providers/hive_adapters.dart';
import 'package:missingpersonapp/features/chat/providers/message_provider.dart';
import 'package:missingpersonapp/features/chat/repository/chat_repository.dart';
import 'package:missingpersonapp/features/chat/services/chat_services.dart';
import 'package:missingpersonapp/features/chat/services/image_upload_service.dart';
import 'package:missingpersonapp/features/chat/services/socket_services.dart';
import 'package:missingpersonapp/features/chat/widgets/chat_list_wrapper.dart';
import 'package:missingpersonapp/features/missingPerson/provider/missing_person_provider.dart';
import 'package:missingpersonapp/features/authentication/provider/user_provider.dart';
import 'package:missingpersonapp/features/authentication/screens/login_page.dart';
import 'package:missingpersonapp/features/missingPerson/screens/missing_person_page.dart';
import 'package:missingpersonapp/features/authentication/services/auth_services.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';
import 'package:missingpersonapp/features/chat/providers/chat_provider.dart';
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _verifyHiveBox<T>(String name) async {
  try {
    final box = await Hive.openBox<T>(name);
    // Verify first item if box exists
    if (box.isNotEmpty) {
      final first = box.getAt(0);
      if (first == null) {
        throw Exception('Corrupted box detected');
      }
    }
  } catch (e) {
    await Hive.deleteBoxFromDisk(name);
    await Hive.openBox<T>(name);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
 // Initialize Hive with robust error handling
  try {
    await Hive.initFlutter();
    HiveAdapters.registerAdapters();
    
    // Verify and repair boxes
    await _verifyHiveBox<Message>('messages');
    await _verifyHiveBox('authBox');
  } catch (e) {
    print('Hive initialization error: $e');
    await Hive.deleteBoxFromDisk('messages');
    await Hive.deleteBoxFromDisk('authBox');
    await Hive.openBox<Message>('messages');
    await Hive.openBox('authBox');
  }


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      Provider<ImageUploadService>(
        create: (context) => ImageUploadService(),
      ),
      Provider<ChatServices>(
        create: (_) => ChatServices(),
      ),
      Provider<SocketService>(
        create: (_) => SocketService(),
      ),
      Provider<ChatRepository>(
        create: (context) => ChatRepository(
          chatServices: context.read<ChatServices>(),
          socketService: context.read<SocketService>(),
          imageUploadService: context.read<ImageUploadService>(),
        ),
      ),
      Provider<AuthService>(
        create: (_) => AuthService(),
      ),
      Provider(
          create: (context) => ChatRepository(
            chatServices: ChatServices(),
            socketService: SocketService(),
            imageUploadService: ImageUploadService(),
          ),
        ),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AllMissingPeopleProvider()),
      ChangeNotifierProvider(create: (_) => CaseProvider()),
      ChangeNotifierProvider(create: (_) => MatchedCaseProvider()),
      ChangeNotifierProvider(create: (_) => CaseMatchedProvider()),
      ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ChangeNotifierProvider(
        create: (_) =>
            DescriptionMatchProvider(apiService: DescriptionMatchService()),
      ),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      // Chat provider that depends on the repository
        ChangeNotifierProxyProvider<ChatRepository, ChatProvider>(
          create: (context) => ChatProvider(
            chatRepository: context.read<ChatRepository>(),
          ),
          update: (context, chatRepository, chatProvider) => 
              chatProvider ?? ChatProvider(chatRepository: chatRepository),
        ),
      ChangeNotifierProvider(
        create: (context) => MessageProvider(
          chatRepository: context.read<ChatRepository>(),
        ),
      ),
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
  bool _isLoading = true; // To show a loading indicator while checking session

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Delay initialization until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Initializing app...');

      // Check if the user is already logged in
      final isLoggedIn = await authService.tryAutoLogin(context);
      print('Auto login result: $isLoggedIn');

      if (isLoggedIn) {
        // Fetch user data if the session is valid
        await authService.getUserData(context);
        print('User data fetched after auto login.');
      }

      setState(() {
        _isLoading = false; // Stop loading
      });
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MissingPerson',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set a transparent AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0, // Remove shadow
          iconTheme: IconThemeData(color: Colors.white), // White icons
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.green,
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.grey,
        ),
      ),
      initialRoute: '/', // Set initialRoute
      routes: {
        '/': (context) => _isLoading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const HomePage(), // Default route
        '/login': (context) => const LoginPage(),
        '/manageProfile': (context) =>
            const AuthGuard(child: ManageProfilePage()),
        '/addPost': (context) => const AuthGuard(child: MissingPersonAddPage()),
        '/feedBack': (context) => const AuthGuard(child: FeedbackPage()),
        '/matchedPeople': (context) => const AuthGuard(child: MatchedCases()),
        '/notification': (context) =>
            const AuthGuard(child: NotificationPage()),
        '/compare': (context) => const ComparePersonPage(),
        '/missingPersonPosted': (context) =>
            const AuthGuard(child: MissingPersonPage()),
        '/settings': (context) => const AuthGuard(child: SettingsPage()),
        '/chatList': (context) => const AuthGuard(
              child: ChatListWrapper(),
            ),
      },
    );
  }
}
