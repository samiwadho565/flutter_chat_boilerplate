import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/controllers/chat_screen_controller.dart';
import 'package:flutter_chat_boilerplate/core/models/userModel.dart';
import 'package:flutter_chat_boilerplate/core/screens/chat_screen.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_app_bar.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class AllUsersScreen extends StatelessWidget {
  final String currentUserId;

 AllUsersScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:CustomAppBar(
        title: 'All Users',isBackArrow: true,),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userId', isNotEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No other users found."));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data();

              final userModel = UserModel.fromMap(data);
              return Column(
                children: [
                  ListTile(
                    leading: CustomCircleAvatar(
                      // isLogo: true,
                      imageUrl: userModel.profileImage??"",radius: 20,),
                    title: Text(userModel.name ?? 'No name'),
                    subtitle: Text(userModel.about ?? ''),
                    onTap: () {
                        Get.lazyPut<ChatController>(() => ChatController());
                        Get.off(() => ChatScreen(), arguments: {"user": userModel, "from": "allUsers"});

                    },
                  ),
                  Divider(color: Colors.green.shade100,),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
