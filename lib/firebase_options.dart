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
    apiKey: 'AIzaSyCZZb1g3PF1y4NJ8VjpO2FTeS5SZuAc_wc',
    appId: '1:187536640839:web:b21658a6c2ec5176fdda62',
    messagingSenderId: '187536640839',
    projectId: 'rawg-eef07',
    authDomain: 'rawg-eef07.firebaseapp.com',
    storageBucket: 'rawg-eef07.firebasestorage.app',
    measurementId: 'G-QB2BL27LM6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqJhKEKNRP11bFsV45IuxuNjxCx6Cgn7w',
    appId: '1:187536640839:android:7f2a200769de1b36fdda62',
    messagingSenderId: '187536640839',
    projectId: 'rawg-eef07',
    storageBucket: 'rawg-eef07.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAa8-VCplCLaaeGuSPA3l0ECm7tyY0Zsj0',
    appId: '1:187536640839:ios:f9b35a2060ab1a5ffdda62',
    messagingSenderId: '187536640839',
    projectId: 'rawg-eef07',
    storageBucket: 'rawg-eef07.firebasestorage.app',
    iosBundleId: 'com.sae.saeFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAa8-VCplCLaaeGuSPA3l0ECm7tyY0Zsj0',
    appId: '1:187536640839:ios:f9b35a2060ab1a5ffdda62',
    messagingSenderId: '187536640839',
    projectId: 'rawg-eef07',
    storageBucket: 'rawg-eef07.firebasestorage.app',
    iosBundleId: 'com.sae.saeFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZZb1g3PF1y4NJ8VjpO2FTeS5SZuAc_wc',
    appId: '1:187536640839:web:878247a34e4ecdc7fdda62',
    messagingSenderId: '187536640839',
    projectId: 'rawg-eef07',
    authDomain: 'rawg-eef07.firebaseapp.com',
    storageBucket: 'rawg-eef07.firebasestorage.app',
    measurementId: 'G-FH8JES8VKK',
  );

}