import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/classes/profile_controller.dart';
import 'package:flutter_chat_boilerplate/core/controllers/chat_screen_controller.dart';
import 'package:flutter_chat_boilerplate/core/models/chatRoomModel.dart';
import 'package:flutter_chat_boilerplate/core/models/userModel.dart';
import 'package:flutter_chat_boilerplate/core/screens/user_screen.dart';
import 'package:flutter_chat_boilerplate/core/services/local_storage_service.dart';
import 'package:flutter_chat_boilerplate/core/services/typing_service.dart';
import 'package:flutter_chat_boilerplate/core/services/user_status_service.dart';
import 'package:flutter_chat_boilerplate/core/utils/time_utils.dart';
import 'package:flutter_chat_boilerplate/core/widgets/conversation_card.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_app_bar.dart';

import 'package:get/get.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final String currentUserId;

  const ConversationsScreen({super.key, required this.currentUserId});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  final TypingService _typingService = TypingService();
  final UserStatusService _userStatusService = UserStatusService();

  Map<String, bool> typingStatusMap = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _userStatusService.setUserOnlineStatus(
      currentUserId: widget.currentUserId,
      isOnline: true,
    );
  }
  void listenToTypingStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    _typingService
        .getTypingStatus(currentUserId: currentUserId, otherUserId: otherUserId)
        .listen((typing) {
      if (mounted) {
        setState(() {
          typingStatusMap[otherUserId] = typing;
        });
      }
    });
  }

  @override
  void dispose() {
    _userStatusService.setUserOnlineStatus(
      currentUserId: widget.currentUserId,
      isOnline: false,
    );
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("did life cycle change${state}");
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive || state ==AppLifecycleState.detached|| state ==AppLifecycleState.hidden) {
      _userStatusService.setUserOnlineStatus(
        currentUserId: widget.currentUserId,
        isOnline: false,
      );
    } else if (state == AppLifecycleState.resumed) {
      _userStatusService.setUserOnlineStatus(
        currentUserId: widget.currentUserId,
        isOnline: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: Colors.black,
          onPressed: (){
        Get.to(() => AllUsersScreen(currentUserId:widget. currentUserId));
      }),
      // extendBodyBehindAppBar: true,

      appBar: CustomAppBar(
     title: "Conversations"),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white

        ),
        child: Column(
          children: [

            Expanded(
           child: StreamBuilder<QuerySnapshot>(
             stream: FirebaseFirestore.instance
                 .collection('chatRoom')
                 .where('participants', arrayContains: widget.currentUserId)
                 .orderBy('timestamp', descending: true)
                 .snapshots(),
             builder: (context, snapshot) {
               if (!snapshot.hasData) {
                 return Center(child: CircularProgressIndicator(color: Colors.black,));
               }

               final chatRooms = snapshot.data!.docs
                   .map((doc) => ChatRoomModel.fromMap(
                   doc.id, doc.data() as Map<String, dynamic>))
                   .toList();

               if (chatRooms.isEmpty) {
                 return Center(child: Text("🕵️ No conversations yet"));
               }
               print("chatRooms.length,${chatRooms.length}");
               return ListView.builder(
                 padding: EdgeInsets.only(top: 10),
                 itemCount:chatRooms.length,
                 itemBuilder: (context, index) {

                   final chat = chatRooms[index];
                   final otherUserId = chat.senderId == widget.currentUserId
                       ? chat.receiverId
                       : chat.senderId;

                   if (!typingStatusMap.containsKey(otherUserId)) {
                     listenToTypingStatus(
                       currentUserId: widget.currentUserId,
                       otherUserId: otherUserId,
                     );
                   }
                   return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                     stream: FirebaseFirestore.instance
                         .collection('users')
                         .where('userId', isEqualTo: otherUserId)
                         .snapshots(),
                     builder: (context, userSnap) {
                       if (!userSnap.hasData) return SizedBox();
                       if (userSnap.data!.docs.isEmpty) return SizedBox();
                       if (!typingStatusMap.containsKey(otherUserId)) {
                         listenToTypingStatus(
                           currentUserId: widget.currentUserId,
                           otherUserId: otherUserId,
                         );
                       }
                       final userModel =
                       UserModel.fromMap(userSnap.data!.docs.first.data());
                       bool isOnline = userModel.isOnline ?? false;
                       userModel.uid = otherUserId;

                return      Padding(
                  padding: const EdgeInsets.only(top: 10,left: 15,right: 15),
                  child: ConversationCard(
                    onDelete: (){},
                    isTyping: typingStatusMap[otherUserId] ?? false,
                    name: userModel.name,
                    readCount:chat.readCount,
                    profileImage: userModel.profileImage ?? '',
                    lastMessage: chat.lastMessage,
                    isOnline: isOnline,
                    readByParticipant: chat.isRead && chat.senderId == widget.currentUserId,
                    sentByYou: chat.senderId == widget.currentUserId,
                    isUnread: !chat.isRead && chat.senderId != widget.currentUserId,
                    time: TimeUtils .formatTimeSmart(chat.timestamp),
                    onPress: () {
                      Get.lazyPut<ChatController>(() => ChatController());
                      Get.to(() => ChatScreen(), arguments: {"user": userModel, "from": "Conversation"});
                    },
                  ),
                );


                     },
                   );

                 },
               );
             },
           ),
         )
          ],
        ),
      ),
    );
  }


}
