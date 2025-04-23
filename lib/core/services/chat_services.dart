import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_boilerplate/core/models/MessageModel.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a message
  Future<void> sendMessage(MessageModel message) async {
    print("called:::;");
    try {
      final chatRoomId = getChatId(message.senderId, message.receiverId);

      // Set the message status to 'Pending' by default

          print("message.id${message.id}");
      // Save message to the 'messages' collection with the initial status as 'Pending'
      await _firestore
          .collection('chatRoom')
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Once the message is saved, update the status to 'Sent'
      //      message.status = 'Sent';

      // Update the last message in the chat room
      await _firestore.collection('chatRoom').doc(chatRoomId).set({
        'lastMessage': message.text,
        'timestamp': Timestamp.fromDate(message.timestamp),
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'isRead': false,

        'lastMessageStatus': message.status,  // Store the status of the last message
      }, SetOptions(merge: true));

      print("Message sent successfully with status: ${message.status}");
    } catch (e) {
      print("Error sending message: $e");
      // Optionally, you can show a dialog or a toast here to notify the user.
    }
  }


  /// Listen to real-time messages

  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    final chatId = getChatId(senderId, receiverId);

    return _firestore
        .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Latest message comes first

        .snapshots()
        .map((snapshot) {
      // Debug log to check what snapshot is returning
      print("Snapshot data: ${snapshot.docs}");

      return snapshot.docs
          .map((doc) {
        // Print each message data
        print("Message Data: ${doc.data()}");
        return MessageModel.fromMap(doc.data(), doc.id);
      })
          .toList();
    });
  }
  /// Delete For EveryOne
  Future<void> deleteForEveryone({
    required String senderId,
    required String receiverId,
    required String messageId,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final messageRef = _firestore
        .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    try {
      await messageRef.update({
        'isDeletedForEveryone': true,
        'text': '🚫 This message was deleted',
      });
      print('Message marked as deleted for everyone.');
    } catch (e) {
      print('Error deleting for everyone: $e');
      throw Exception('Failed to delete message for everyone.');
    }
  }

  /// Delete one or more messages
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
  }


  /// Generate unique chat ID based on sender & receiver IDs
  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode
        ? '${uid1}_$uid2'
        : '${uid2}_$uid1';
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(String senderId, String receiverId, String messageId) async {
    final chatId = getChatId(senderId, receiverId);
    // String deviceId = await getDeviceId();

    await _firestore
        .collection('chatRoom')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});

    await _firestore.collection('chatRoom').doc(chatId).set({
      // ' readBy.$deviceId': true,
      'isRead': true,
      // 'lastMessageStatus': message.status,  // Store the status of the last message
    }, SetOptions(merge: true));
  }

  /// Update typing status for a user in a chat
  // Future<void> updateTypingStatus({
  //   required String senderId,
  //   required String receiverId,
  //   required bool isTyping,
  // }) async {
  //   final chatId = getChatId(senderId, receiverId);
  //   final fieldKey = senderId;
  //
  //   await _firestore.collection('chatRoom').doc(chatId).set({
  //     'typingStatus': {fieldKey: isTyping}
  //   }, SetOptions(merge: true));
  // }
  Future<void> updateTypingStatus({
    required String senderId,
    required String receiverId,
    required bool isTyping,
  }) async {
    final chatId = getChatId(senderId, receiverId);

    await _firestore.collection('chatRoom').doc(chatId).set({
      'typingStatus': {senderId: isTyping}
    }, SetOptions(merge: true));
  }

  // Stream<bool> getTypingStatus({
  //   required String currentUserId,
  //   required String otherUserId,
  // }) {
  //   final chatId = getChatId(currentUserId, otherUserId);
  //
  //   return _firestore
  //       .collection('chatRoom')

  //       .doc(chatId)
  //       .snapshots()
  //       .map((doc) {
  //     final data = doc.data();
  //     if (data != null && data['typingStatus'] != null) {
  //       return data['typingStatus'][otherUserId] ?? false;
  //     }
  //     return false;
  //   });
  // }

  /// Listen to other user's typing status
  Stream<bool> getTypingStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatId = getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chatRoom')
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
  // Future<void> setUserOnlineStatus({
  //   required String currentUserId,
  //   required String otherUserId,
  //   required bool isOnline,
  // }) async {
  //   final chatId = getChatId(currentUserId, otherUserId);
  //
  //   print('📡 Updating online status for: $currentUserId');
  //   print('🆔 Chat ID: $chatId');
  //   print('📍 Status: $isOnline');
  //
  //   await _firestore.collection('chatRoom').doc(chatId).set({
  //     'onlineStatus': {
  //       currentUserId: {
  //         'isOnline': isOnline,
  //         'lastSeen': isOnline ? null : DateTime.now(),
  //       }
  //     }
  //   }, SetOptions(merge: true));
  //
  //   print('✅ Status updated in Firestore!');
  // }
  //
  // Future<void> setUserOnlineStatus({
  //   required String currentUserId,
  //   required String otherUserId,
  //   required bool isOnline,
  // }) async {
  //   final chatId = getChatId(currentUserId, otherUserId);
  //   await _firestore.collection('chatRoom').doc(chatId).set({
  //     'userStatus': {
  //       currentUserId: isOnline,
  //     },
  //     'lastSeen': {
  //       currentUserId: isOnline ? null : FieldValue.serverTimestamp(),
  //     },
  //   }, SetOptions(merge: true));
  // }

  Future<void> setUserOnlineStatus({
  required String currentUserId,
  required bool isOnline,
  }) async {
  try {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('userId', isEqualTo: currentUserId)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
  print('❌ User not found');
  return;
  }

  final docId = snapshot.docs.first.id;

  await FirebaseFirestore.instance.collection('users').doc(docId).update({
  'isOnline': isOnline,
  'lastSeen':  FieldValue.serverTimestamp(),
  });

  print('✅ Status updated');
  } catch (e) {
  print('❌ Error updating status: $e');
  }
  }



  // Stream<bool> getUserOnlineStatus({
  //   required String currentUserId,
  //   required String otherUserId,
  // }) {
  //   final chatId = getChatId(currentUserId, otherUserId);
  //
  //   return _firestore.collection('chatRoom').doc(chatId).snapshots().map((doc) {
  //     final data = doc.data();
  //     if (data == null) return false;
  //     final statusMap = data['userStatus'] as Map<String, dynamic>?;
  //     return statusMap?[otherUserId] ?? false;
  //   });
  // }
  // Stream<Map<String, dynamic>> getUserOnlineStatus({
  //   required String currentUserId,
  //   required String otherUserId,
  // }) {
  //
  //   final chatId = getChatId(currentUserId, otherUserId);
  //   return _firestore.collection('chatRoom').doc(chatId).snapshots().map((doc) {
  //     final data = doc.data();
  //     if (data == null) return {};
  //
  //     final userStatus = (data['userStatus'] ?? {})[otherUserId] ?? false;
  //     final lastSeen = (data['lastSeen'] ?? {})[otherUserId];
  //
  //     return {
  //       'isOnline': userStatus,
  //       'lastSeen': lastSeen,
  //     };
  //   });
  // }

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

  //this is dummy code for testing
  // void setUserOnlineStatusDummy(String userId) async {
  //   String deviceId = await getDeviceId();
  //   String sessionId = '$userId-$deviceId';
  //
  //   await FirebaseFirestore.instance.collection('userSessions').doc(sessionId).set({
  //     'userId': userId,
  //     'deviceId': deviceId,
  //     'isOnline': true,
  //     'lastUpdated': FieldValue.serverTimestamp(),
  //   });
  // }
  //this is dummy code for testing
  // void setUserOfflineStatus(String userId) async {
  //   String deviceId = await getDeviceId();
  //   String sessionId = '$userId-$deviceId';
  //
  //   await FirebaseFirestore.instance.collection('userSessions').doc(sessionId).update({
  //     'isOnline': false,
  //     'lastUpdated': FieldValue.serverTimestamp(),
  //   });
  // }


}
