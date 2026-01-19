import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCiUwA4kbmYf2xNNvsCTt7Nt9ve3I3wOEM",
    authDomain: "perpustakaan-kita-feb57.firebaseapp.com",
    projectId: "perpustakaan-kita-feb57",
    storageBucket: "perpustakaan-kita-feb57.firebasestorage.app",
    messagingSenderId: "746155458593",
    appId: "1:746155458593:web:0d942c1c419f0e23c52360",
    measurementId: "G-9EGVBH7SV7",
  );
}