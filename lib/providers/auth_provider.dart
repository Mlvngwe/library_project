import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _userRole;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isAuthenticated => _user != null;

  // Fungsi Login Real dengan Firebase
  Future<void> login(String email, String password) async {
    try {
      // 1. Proses Autentikasi ke Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // 2. Ambil data role user dari Firestore
      // Asumsinya kamu punya collection 'users' dengan document ID = UID user
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        _userRole = userDoc['role'];
        debugPrint("DAPET ROLE: $_userRole"); // TAMBAHKAN INI
      } else {
        debugPrint("GA KETEMU DI FIRESTORE, UID: ${_user!.uid}"); // TAMBAHKAN INI
        _userRole = 'member';
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // Lempar pesan error yang mudah dibaca user
      if (e.code == 'user-not-found') {
        throw 'Email tidak terdaftar.';
      } else if (e.code == 'wrong-password') {
        throw 'Password salah.';
      } else {
        throw e.message ?? 'Terjadi kesalahan saat login.';
      }
    } catch (e) {
      throw 'Gagal login: $e';
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userRole = null;
    notifyListeners();
  }

  // Cek status login saat aplikasi pertama kali dibuka
  void checkCurrentUser() {
    _user = _auth.currentUser;
    // Note: Untuk role saat auto-login, biasanya perlu fetch ulang dari Firestore
    // Tapi untuk deadline, bisa diset via database sinkronisasi nantinya
    notifyListeners();
  }

// Fungsi untuk Register (Bisa dipakai Member atau Manager buat tambah staff)
Future<void> registerUser(String email, String password, String role) async {
  try {
    // 1. Buat akun di Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    // 2. Simpan role-nya ke Firestore collection 'users'
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': role, // 'member' atau 'librarian'
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Opsional: Jika yang daftar adalah member baru, langsung login-kan.
    // Jika manager yang daftarin staff, kita jangan ganti status login manager-nya.
  } catch (e) {
    throw 'Gagal mendaftarkan user: $e';
  }
}

}

