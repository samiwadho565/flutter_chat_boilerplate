import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_boilerplate/core/services/chat_utils.dart';

class TypingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateTypingStatus({
    required String senderId,
    required String receiverId,
    required bool isTyping,
  }) async {
    final chatId = ChatUtils.getChatId(senderId, receiverId);
    await _firestore.collection('chatRoom').doc(chatId).set({
      'typingStatus': {senderId: isTyping}
    }, SetOptions(merge: true));
  }

  Stream<bool> getTypingStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatId = ChatUtils.getChatId(currentUserId, otherUserId);
    return _firestore.collection('chatRoom').doc(chatId).snapshots().map((doc) {
      final data = doc.data();
      return data?['typingStatus']?[otherUserId] ?? false;
    });
  }
}