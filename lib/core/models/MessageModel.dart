import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? mediaUrl;
  final String? mediaType;
  final bool isRead;
  final DateTime timestamp;
  final List<String>? reactions;
  final String? replyToMessageId;
  final bool isEdited;
  final String messageType; // "text", "image", "video", "voice"
  final List<String>? deletedFor;
  final bool? isDeletedForEveryone;
  final bool ?isDeletedForMe;
final int?  readCount; // Initial count when first message is sent

  String status;
  MessageModel({
    this.id,
    this.readCount, // Initial count when first message is sent
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.mediaUrl,
    this.mediaType,
    required this.isRead,
    required this.timestamp,
    this.reactions,
    this.replyToMessageId,
    this.isDeletedForEveryone,
    this.isDeletedForMe,
    required this.isEdited,
    required this.messageType,
    this.deletedFor,
    this.status = 'pending',
  });
  MessageModel copyWith({
int ?readCount,

    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    String? mediaUrl,
    String? mediaType,
    bool? isRead,
    DateTime? timestamp,
    List<String>? reactions,
    String? replyToMessageId,
    bool? isEdited,
    String? messageType,
    List<String>? deletedFor,
    bool? isDeletedForEveryone,
    bool? isDeletedForMe,
    String? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      readCount: readCount??this.readCount,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      messageType: messageType ?? this.messageType,
      deletedFor: deletedFor ?? this.deletedFor,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      isDeletedForMe: isDeletedForMe ?? this.isDeletedForMe,
      status: status ?? this.status,
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      readCount: map['readCount']??0,
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
      isDeletedForEveryone: map['isDeleteForEveryOne'],
      isDeletedForMe: map['isDeletedForMe'],
      deletedFor: List<String>.from(map['deletedFor'] ?? []),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'readCount':readCount,
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
      'isDeletedForEveryone':isDeletedForEveryone??false,
    ' isDeletedForMe':isDeletedForMe??false,
      'messageType': messageType,
      'deletedFor': deletedFor ?? [],
      'status': status,
    };
  }
}
