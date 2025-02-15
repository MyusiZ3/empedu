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
    apiKey: 'AIzaSyBRt-ckV6VffgzkASexzQNb54R-9duGH1s',
    appId: '1:145908719158:web:0dfdfe99e897d1469c8297',
    messagingSenderId: '145908719158',
    projectId: 'empedu-a57c3',
    authDomain: 'empedu-a57c3.firebaseapp.com',
    storageBucket: 'empedu-a57c3.firebasestorage.app',
    measurementId: 'G-GW4NZWKQFP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8gZuI-pDS9m8nbwI2ue7drJ_TcMQ-_Qc',
    appId: '1:145908719158:android:ca6fa4961893f0119c8297',
    messagingSenderId: '145908719158',
    projectId: 'empedu-a57c3',
    storageBucket: 'empedu-a57c3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCPH8f0-iLHn4bK3fFSj3PrGwx6PFhLaY4',
    appId: '1:145908719158:ios:f0c98a70ea3a36a39c8297',
    messagingSenderId: '145908719158',
    projectId: 'empedu-a57c3',
    storageBucket: 'empedu-a57c3.firebasestorage.app',
    iosBundleId: 'com.imyusi.empedu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCPH8f0-iLHn4bK3fFSj3PrGwx6PFhLaY4',
    appId: '1:145908719158:ios:f0c98a70ea3a36a39c8297',
    messagingSenderId: '145908719158',
    projectId: 'empedu-a57c3',
    storageBucket: 'empedu-a57c3.firebasestorage.app',
    iosBundleId: 'com.imyusi.empedu',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBRt-ckV6VffgzkASexzQNb54R-9duGH1s',
    appId: '1:145908719158:web:2d3d127be4f7df929c8297',
    messagingSenderId: '145908719158',
    projectId: 'empedu-a57c3',
    authDomain: 'empedu-a57c3.firebaseapp.com',
    storageBucket: 'empedu-a57c3.firebasestorage.app',
    measurementId: 'G-X492JL9N92',
  );
}
