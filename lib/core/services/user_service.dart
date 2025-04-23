import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        return userDoc.data();
      } else {
        print('❌ User document not found for UID: ${currentUser.uid}');
        return null;
      }
    } catch (e) {
      print('🔥 Error fetching user data: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({required String name, required String about}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'userName': name,
        'about': about,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }


}
