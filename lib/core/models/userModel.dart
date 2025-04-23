import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  final String name;
  final String? about;
  final String? email;
  final String? profileImage;
  final bool? isOnline;
  final DateTime? lastSeen;
  final bool? isTyping;

  UserModel({
    this.uid,
    required this.name,
    this.about,
    this.email,
    this.profileImage,
    this.isOnline,
    this.lastSeen,
    this.isTyping,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['userId'] ?? '',
      name: map['userName'] ?? '',
      email: map['email'] ?? '',
      about: map['about']??'',
      profileImage: map['profileImage'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? (map['lastSeen'] as Timestamp).toDate() : null,
      isTyping: map['isTyping'] ?? false,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': name,
      'email': email,
      'profileImage': profileImage,
      'about':about,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isTyping': isTyping,
    };
  }
}
