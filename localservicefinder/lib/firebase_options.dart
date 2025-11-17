import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs4InDhOCqAtHapG58SeGeByzsGkGXmnk',
    appId: '1:299236667027:web:914affc6f262e35f852766',
    messagingSenderId: '299236667027',
    projectId: 'localservicefinder-e2a8d',
    authDomain: 'localservicefinder-e2a8d.firebaseapp.com',
    storageBucket: 'localservicefinder-e2a8d.firebasestorage.app',
    measurementId: 'G-0L4TF4NW87',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfazV7C-gqDjZpWqBqdhQ0w1UTDvrtQPc',
    appId: '1:299236667027:android:58b54a871919d37b852766',
    messagingSenderId: '299236667027',
    projectId: 'localservicefinder-e2a8d',
    storageBucket: 'localservicefinder-e2a8d.firebasestorage.app',
  );
}
