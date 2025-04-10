import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_boilerplate/core/models/MessageModel.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a message
  Future<void> sendMessage(MessageModel message) async {
    final chatId = _getChatId(message.senderId, message.receiverId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    // Update last message preview (optional)
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'timestamp': Timestamp.fromDate(message.timestamp),
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'isRead': false,
    }, SetOptions(merge: true));
  }

  /// Listen to real-time messages
  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    final chatId = _getChatId(senderId, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Generate unique chat ID based on sender & receiver IDs
  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode
        ? '${uid1}_$uid2'
        : '${uid2}_$uid1';
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(String senderId, String receiverId, String messageId) async {
    final chatId = _getChatId(senderId, receiverId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  /// Update typing status for a user in a chat
  Future<void> updateTypingStatus({
    required String senderId,
    required String receiverId,
    required bool isTyping,
  }) async {
    final chatId = _getChatId(senderId, receiverId);
    final fieldKey = senderId;

    await _firestore.collection('chats').doc(chatId).set({
      'typingStatus': {fieldKey: isTyping}
    }, SetOptions(merge: true));
  }

  /// Listen to other user's typing status
  Stream<bool> getTypingStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatId = _getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data != null && data['typingStatus'] != null) {
        return data['typingStatus'][otherUserId] ?? false;
      }
      return false;
    });
  }

}
