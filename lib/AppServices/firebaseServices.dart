import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '',
    appId: '1:922412940403:android:295da3dc57b2f1afbb7e06',
    messagingSenderId: '922412940403',
    projectId: 'streaming-demo-app',
    databaseURL: 'https://streaming-demo-app-default-rtdb.firebaseio.com',
    storageBucket: 'streaming-demo-app.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "",
    authDomain: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
    appId: "",
    measurementId: "",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    databaseURL: '',
    storageBucket: '',
    iosBundleId: '',
  );
}
