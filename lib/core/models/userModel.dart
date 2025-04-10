import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final bool isOnline;
  final DateTime lastSeen;
  final bool isTyping;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage,
    required this.isOnline,
    required this.lastSeen,
    required this.isTyping,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp).toDate(),
      isTyping: map['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'isTyping': isTyping,
    };
  }
}
