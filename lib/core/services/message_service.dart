import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_boilerplate/core/models/MessageModel.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String uid1, String uid2) =>
      uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';

  Future<void> sendMessage(MessageModel message) async {
    final chatRoomId = getChatId(message.senderId, message.receiverId);

    try {
      final unreadMessages = await _firestore
          .collection('chatRoom')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: message.senderId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      // Update read count for unread messages
      for (var doc in unreadMessages.docs) {
        final currentCount = (doc.data()['readCount'] ?? 0) as int; // Default to 0 if not found
        batch.update(doc.reference, {
          'readCount': currentCount + 1,
        });
      }

      // Create new message with ID
      final messageId = _firestore
          .collection('chatRoom')
          .doc(chatRoomId)
          .collection('messages')
          .doc()
          .id;

      final messageWithId = message.copyWith(
        id: messageId,
        status: 'Sent',
        readCount: 0, // New message has 0 read count initially
      );

      // Add the new message to the chat room
      batch.set(
        _firestore.collection('chatRoom').doc(chatRoomId).collection('messages').doc(messageId),
        messageWithId.toMap(),
      );

      // Update the chat room document with the latest message info
      batch.set(
        _firestore.collection('chatRoom').doc(chatRoomId),
        {
          'lastMessage': message.text,
          'timestamp': Timestamp.fromDate(message.timestamp),
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'isRead': false,
          'lastMessageId': messageId,
          'participants': [message.senderId, message.receiverId],
          'lastMessageStatus': 'Sent',
          'readCount': FieldValue.increment(1), // Increment the readCount in the chatRoom
        },
        SetOptions(merge: true),
      );

      // Commit the batch
      await batch.commit();

    } catch (e) {
    }
  }



  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    final chatId = getChatId(senderId, receiverId);
    return _firestore
        .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList());
  }

// Add delete/update methods here too



  Future<void> deleteMessages({
    required String senderId,
    required String receiverId,
    required List<String> messageIds,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final batch = _firestore.batch();

    for (String messageId in messageIds) {
      final messageRef = _firestore
          .collection('chatRoom')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      batch.delete(messageRef);

    }

    try {
      await batch.commit();
      print('Messages deleted successfully');
    } catch (e) {
      print('Error deleting messages: $e');
      throw Exception('Failed to delete messages');
    }
  }

  Future<void> updateMessage({
    required String senderId, // current user
    required String receiverId,
    required String messageId,
    required String newText,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final messageRef = _firestore
        .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final messageSnapshot = await messageRef.get();

    if (!messageSnapshot.exists) {
      throw Exception('Message not found');
    }

    final data = messageSnapshot.data()!;
    final originalSenderId = data['senderId'];
    final timestamp = (data['timestamp'] as Timestamp).toDate();

    // Check if sender matches the message sender
    if (originalSenderId != senderId) {
      throw Exception('You can only edit your own messages.');
    }

    // Check 1-hour time window
    if (DateTime.now().difference(timestamp).inMinutes > 60) {
      throw Exception('⏱ You can only edit messages within 1 hour.');
    }

    await messageRef.update({
      'text': newText,
      'isEdited': true,
    });
    final chatRoomRef = _firestore.collection('chatRoom').doc(chatId);
    final chatRoomSnapshot = await chatRoomRef.get();

    if (chatRoomSnapshot.exists) {
      final lastMessageId = chatRoomSnapshot.data()?['lastMessageId'];
print("chatRoomSnapshot.exists${lastMessageId}");
      // Agar yeh message hi last message hai, toh update karo
      if (lastMessageId == messageId) {
        await chatRoomRef.update({
          'lastMessage': newText,
          'isEdited': true,
        });
      }}
    }
  Future<void> markMessageAsRead(String senderId, String receiverId, String messageId) async {
    final chatId = getChatId(senderId, receiverId);
    await _firestore
        .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});

    await _firestore.collection('chatRoom').doc(chatId).set({
      'isRead': true,
      'readCount':0
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessagesForCurrentUser({
    required String senderId,
    required String receiverId,
    required List<String> messageIds,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    final chatId = getChatId(senderId, receiverId);

    for (final messageId in messageIds) {
      final messageRef = _firestore .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
      batch.update(messageRef, {
        'deletedFor':FieldValue.arrayUnion([senderId])
      });
    }

    await batch.commit();
  }

}
