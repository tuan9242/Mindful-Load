import 'package:firebase_core/firebase_core.dart';
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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8UECu38B-UC2XVGaD_0RROI_SxrB8-DE',
    appId: '1:759026003067:web:c99ea62d67bed47a30c6de',
    messagingSenderId: '759026003067',
    projectId: 'btl-1771020719',
    authDomain: 'btl-1771020719.firebaseapp.com',
    storageBucket: 'btl-1771020719.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8UECu38B-UC2XVGaD_0RROI_SxrB8-DE',
    appId: '1:759026003067:android:c99ea62d67bed47a30c6de',
    messagingSenderId: '759026003067',
    projectId: 'btl-1771020719',
    storageBucket: 'btl-1771020719.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8UECu38B-UC2XVGaD_0RROI_SxrB8-DE',
    appId: '1:759026003067:ios:c99ea62d67bed47a30c6de',
    messagingSenderId: '759026003067',
    projectId: 'btl-1771020719',
    storageBucket: 'btl-1771020719.firebasestorage.app',
    iosBundleId: 'com.example.mindfulLoad',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA8UECu38B-UC2XVGaD_0RROI_SxrB8-DE',
    appId: '1:759026003067:web:c99ea62d67bed47a30c6de',
    messagingSenderId: '759026003067',
    projectId: 'btl-1771020719',
    authDomain: 'btl-1771020719.firebaseapp.com',
    storageBucket: 'btl-1771020719.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );
}
