import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// BUILD
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {   //for quick testing on web
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {     //for final testing 
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBX5mL3iSO5uO0r1IVDMSuNF1tz3LUicHM',
    authDomain: 'todolist-app-57839.firebaseapp.com',
    projectId: 'todolist-app-57839',
    storageBucket: 'todolist-app-57839.firebasestorage.app',
    messagingSenderId: '234537769136',
    appId: '1:234537769136:web:e8a4280fd1e04ae9d58375',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIKnIkmAoHAXMAiFT95eFfMhF-WDrBmxc',
    appId: '1:234537769136:android:90d4db70ee6b412cd58375',
    messagingSenderId: '234537769136',
    projectId: 'todolist-app-57839',
    storageBucket: 'todolist-app-57839.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIKnIkmAoHAXMAiFT95eFfMhF-WDrBmxc',
    appId: '1:234537769136:android:90d4db70ee6b412cd58375',
    messagingSenderId: '234537769136',
    projectId: 'todolist-app-57839',
    storageBucket: 'todolist-app-57839.firebasestorage.app',
    iosBundleId: 'com.example.todoApp',
  );
}
