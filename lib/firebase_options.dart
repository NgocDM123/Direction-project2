// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAb3MeNxuZRGNYVKTXVXhsE7V-6DK_TRmQ',
    appId: '1:279831183939:web:bc47993bf9d8e0bea04af6',
    messagingSenderId: '279831183939',
    projectId: 'directionapp-8aee1',
    authDomain: 'directionapp-8aee1.firebaseapp.com',
    databaseURL: 'https://directionapp-8aee1-default-rtdb.firebaseio.com',
    storageBucket: 'directionapp-8aee1.appspot.com',
    measurementId: 'G-RJ5HTGF1CG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCu3JeTdkUK07PjpHlalCfJ46cnJP4Kwwo',
    appId: '1:279831183939:android:5c28ca0c96213262a04af6',
    messagingSenderId: '279831183939',
    projectId: 'directionapp-8aee1',
    databaseURL: 'https://directionapp-8aee1-default-rtdb.firebaseio.com',
    storageBucket: 'directionapp-8aee1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrcReTHFyx9CzxCIo8XpMuA4oRk-Voxls',
    appId: '1:279831183939:ios:bbdbdac81b5a97d9a04af6',
    messagingSenderId: '279831183939',
    projectId: 'directionapp-8aee1',
    databaseURL: 'https://directionapp-8aee1-default-rtdb.firebaseio.com',
    storageBucket: 'directionapp-8aee1.appspot.com',
    iosClientId: '279831183939-rjfv83fk1vutq8u7p4v8rjcvc5801b68.apps.googleusercontent.com',
    iosBundleId: 'com.example.direction',
  );
}
