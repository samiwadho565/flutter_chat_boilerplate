import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? mediaUrl;
  final String? mediaType; // image, video, audio
  final bool isRead;
  final DateTime timestamp;
  final List<String>? reactions; // ❤️ 😂 etc.
  final String? replyToMessageId;
  final bool isEdited;
  final String messageType; // "text", "image", "video", "voice"

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.mediaUrl,
    this.mediaType,
    required this.isRead,
    required this.timestamp,
    this.reactions,
    this.replyToMessageId,
    required this.isEdited,
    required this.messageType,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
      isRead: map['isRead'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      reactions: List<String>.from(map['reactions'] ?? []),
      replyToMessageId: map['replyToMessageId'],
      isEdited: map['isEdited'] ?? false,
      messageType: map['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactions,
      'replyToMessageId': replyToMessageId,
      'isEdited': isEdited,
      'messageType': messageType,
    };
  }
}
