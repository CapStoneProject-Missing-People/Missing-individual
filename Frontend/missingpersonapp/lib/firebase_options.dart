// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjw3OfnHFe8My9YFyuIU_uWYYjbmto50A',
    appId: '1:190884749765:web:cadf491e0c68d362a46bac',
    messagingSenderId: '190884749765',
    projectId: 'missingpersonnotification',
    authDomain: 'missingpersonnotification.firebaseapp.com',
    storageBucket: 'missingpersonnotification.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVRr4EePdD0CyZAVYdcdyGjruumlXvGIQ',
    appId: '1:190884749765:android:7e7b351127ed9a69a46bac',
    messagingSenderId: '190884749765',
    projectId: 'missingpersonnotification',
    storageBucket: 'missingpersonnotification.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnSM8p8Nj7czqnTOS1H-lKVvpbJj27nIE',
    appId: '1:190884749765:ios:b3d668f8c10a6a76a46bac',
    messagingSenderId: '190884749765',
    projectId: 'missingpersonnotification',
    storageBucket: 'missingpersonnotification.appspot.com',
    iosBundleId: 'com.example.missingpersonapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnSM8p8Nj7czqnTOS1H-lKVvpbJj27nIE',
    appId: '1:190884749765:ios:b3d668f8c10a6a76a46bac',
    messagingSenderId: '190884749765',
    projectId: 'missingpersonnotification',
    storageBucket: 'missingpersonnotification.appspot.com',
    iosBundleId: 'com.example.missingpersonapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjw3OfnHFe8My9YFyuIU_uWYYjbmto50A',
    appId: '1:190884749765:web:72842aed0cec24a1a46bac',
    messagingSenderId: '190884749765',
    projectId: 'missingpersonnotification',
    authDomain: 'missingpersonnotification.firebaseapp.com',
    storageBucket: 'missingpersonnotification.appspot.com',
  );
}
