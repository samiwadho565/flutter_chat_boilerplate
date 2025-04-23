import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String chatRoomId;
  final String lastMessage;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;
  final List<String> participants;
  final bool isRead;
  final int readCount;

  ChatRoomModel({
    required this.readCount,
    required this.chatRoomId,
    required this.lastMessage,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    required this.participants,
    required this.isRead,
  });

  factory ChatRoomModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoomModel(
      chatRoomId: id,
      readCount: map['readCount']??0,
      lastMessage: map['lastMessage'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      isRead: map['isRead'] ?? false,
    );
  }
}
