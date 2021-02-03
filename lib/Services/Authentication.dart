import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signIn(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user.uid;
  }

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

  Future<String> signUp(String email, String password) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
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

  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser;
    await user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    try {
      User user = _firebaseAuth.currentUser;
      return user.emailVerified;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getReAuthenticatedUser(String password) async {
    User user = _firebaseAuth.currentUser;
    UserCredential authResult = await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: user.email,
        password: password,
      ),
    );

    return authResult.user;
  }

  Future<String> changeEmail(User reAuthUser, String newEmail) async {
    //FirebaseUser reAuthUser = await getReAuthenticatedUser(currentPassword);
    await reAuthUser.updateEmail(newEmail);
    return reAuthUser.uid;
  }

  Future<void> changePassword(User reAuthUser, String newPassword) async {
    //FirebaseUser reAuthUser = await getReAuthenticatedUser(oldPassword);
    await reAuthUser.updatePassword(newPassword);
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
