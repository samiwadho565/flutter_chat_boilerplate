
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setUserOnlineStatus({
    required String currentUserId,
    required bool isOnline,
  }) async {
    final userSnap = await _firestore
        .collection('users')
        .where('userId', isEqualTo: currentUserId)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) return;

    final docId = userSnap.docs.first.id;
    await _firestore.collection('users').doc(docId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });

    print("status updated");
  }

  Stream<Map<String, dynamic>> getUserOnlineStatus({
    // required String currentUserId,
    required String otherUserId,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: otherUserId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        return {};
      }
    });
  }
}