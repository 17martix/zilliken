import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> anonymousSignIn() async {
    UserCredential result = await _firebaseAuth.signInAnonymously();
    User? user = result.user;
    return user?.uid;
  }

  User? getCurrentUser() {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  FirebaseAuth getAuth() {
    return _firebaseAuth;
  }
}
