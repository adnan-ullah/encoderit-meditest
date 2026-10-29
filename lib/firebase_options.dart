// File generated manually from android/app/google-services.json for multi-platform init.
// Prefer regenerating with `flutterfire configure` when dedicated Web/iOS/macOS/Windows
// apps are added in the Firebase console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // Apple platforms require an `:ios:` GOOGLE_APP_ID format.
        return apple;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChsQEuBLsAXD5Hy9dAwK1yBR9Rj7d47m4',
    appId: '1:503892071126:android:48ef1f2bf633b9b2652f77',
    messagingSenderId: '503892071126',
    projectId: 'meditest-fe4a5',
    databaseURL:
        'https://meditest-fe4a5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'meditest-fe4a5.appspot.com',
  );

  /// Apple (iOS/macOS). Uses ios-format appId derived from the Android app until
  /// a real iOS/macOS app is registered via `flutterfire configure`.
  static const FirebaseOptions apple = FirebaseOptions(
    apiKey: 'AIzaSyChsQEuBLsAXD5Hy9dAwK1yBR9Rj7d47m4',
    appId: '1:503892071126:ios:48ef1f2bf633b9b2652f77',
    messagingSenderId: '503892071126',
    projectId: 'meditest-fe4a5',
    databaseURL:
        'https://meditest-fe4a5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'meditest-fe4a5.appspot.com',
    iosBundleId: 'com.enocderit.meditest.healthcareHomelab',
  );

  /// Web uses the same Firebase project. Register a Web app in Firebase Console
  /// and replace [appId] with the generated `1:...:web:...` value when available.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChsQEuBLsAXD5Hy9dAwK1yBR9Rj7d47m4',
    appId: '1:503892071126:web:meditestfe4a5webapp',
    messagingSenderId: '503892071126',
    projectId: 'meditest-fe4a5',
    authDomain: 'meditest-fe4a5.firebaseapp.com',
    databaseURL:
        'https://meditest-fe4a5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'meditest-fe4a5.appspot.com',
  );
}
