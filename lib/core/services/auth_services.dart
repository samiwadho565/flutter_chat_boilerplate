import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_boilerplate/core/models/app_user_Model.dart';
import 'package:flutter_chat_boilerplate/core/screens/email_sent_success_screen.dart';
import 'package:flutter_chat_boilerplate/core/utils/app_utils.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': email,
          'userName': username,
          'profileImage': '',
          'isOnline': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return userCredential;
      } else {
        return null;
      }
    } catch (e, s) {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Sign In Error: ${e.message}');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ Google sign-in aborted by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;

      final userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': user.email,
          'userName': user.displayName ?? '',
          'profileImage': user.photoURL ?? '',
          'isOnline': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  AppUserModel? getUserData() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return AppUserModel(
        email: user.email!,
        username: user.displayName ?? '',
      );
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {

      AppUtils. showLoadingDialog();
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppUtils.hideLoadingDialog();// 👈 Hide the loader popup

    await  Future.delayed(Duration(milliseconds: 500));
      Get.to(() => PasswordResetSuccessScreen(email: email));
    } catch (e) {
      rethrow;
    }
  }

}


