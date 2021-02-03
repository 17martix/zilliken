import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential result;
    result = await _firebaseAuth.signInWithCredential(credential);

    //result = await _firebaseAuth.currentUser.linkWithCredential(credential);

    //UserCredential result = await _firebaseAuth.signInWithCredential(credential);
    User user = result.user;
    return user.uid;
  }

  Future<String> anonymousSignIn() async {
    UserCredential result = await _firebaseAuth.signInAnonymously();
    User user = result.user;
    return user.uid;
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
