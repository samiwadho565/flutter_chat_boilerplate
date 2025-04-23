import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/controllers/chat_screen_controller.dart';
import 'package:flutter_chat_boilerplate/core/utils/time_utils.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_text_field.dart';
import 'package:flutter_chat_boilerplate/core/widgets/message_option_bottom_sheet.dart';
import 'package:get/get.dart';

class ChatScreen extends GetView<ChatController> {
  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Obx(() => Expanded(child: _buildMessageList(context))),
          CustomTextField(
            isForMessageScreen: true,
            controller: controller.textController,
            isRecording: controller.isRecording.value,
            // onSend: controller.sendMessage,
            onSend: () {
              if (controller.isEditing.value) {
                controller.editMessage(
                  messageId: controller.editingMessageId!,
                  newText:controller.textController. text.trim(),
                );
                controller.isEditing.value = false;
                controller.editingMessageId = null;
                controller.textController.clear();
                controller.selectedMessages.clear();
              } else {
                controller.sendMessage();
              }
            },

            onChanged: (_) => controller.updateTypingStatus(),
            onRecord: controller.toggleRecording,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      leadingWidth: 25,
      title: Row(
        children: [
          // CircleAvatar(
          //   backgroundImage: NetworkImage(controller.user.profileImage ?? ""),
          // ),
          CustomCircleAvatar(
            imageUrl: controller.user.profileImage??"",radius: 17,),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              Obx(() {
                if (controller.isTyping.value) {
                  return const Text(
                    "is typing...",
                    style: TextStyle(color: Colors.indigo, fontSize: 11),
                  );
                } else if (controller.isOtherUserOnline.value) {
                  return const Text(
                    "Online",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  );
                } else if (controller.lastSeen.value != null) {
                  final duration =
                      DateTime.now().difference(controller.lastSeen.value!);
                  return Text(
                    "Last seen ${TimeUtils.formatTimeSmart(controller.lastSeen.value!)}",
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  );
                } else {
                  return const Text(
                    "Offline",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
              }),
            ],
          ),
        ],
      ),
      actions: [_buildAppBarActions(context)],
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    return Obx(() {
      final selectedMessages = controller.selectedMessages;
      if (selectedMessages.isEmpty) return const SizedBox.shrink();

      return IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          MessageOptionsBottomSheet.show(context, controller);
        },
      );
    });
  }

  Widget _buildMessageList(BuildContext context) {
    return     controller. isLoading .value?Center(child: Text("Loading...")):

    controller.messageList.isEmpty?
    Center(child: Text("Start a conversation now! 🗨️")):
    ListView.builder(
      reverse: true,
      itemCount: controller.messageList.length,
      itemBuilder: (context, index) {
        final message = controller.messageList[index];
        final isCurrentUser = message.senderId == controller.currentUserId;

        return GestureDetector(
          onLongPress: () => controller.toggleSelection(message),
          onTap: () {
            if (controller.selectedMessages.isNotEmpty) {
              controller.toggleSelection(message);
              controller.isCurrentUser.value = isCurrentUser;
            }
          },
          child: Obx(() {
            final isSelected = controller.selectedMessages.contains(message);
            return Container(
              color: isSelected ? Colors.green.shade100 : Colors.transparent,
              child: Align(
                alignment: isCurrentUser
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? Colors.black
                            :  Color(0xfff3f3f3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: message.isDeletedForEveryone == true
                            ? const Text(
                                "🚫 This message was deleted",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                              )
                            : message.messageType == 'Text'
                                ? Text(
                                    message.text,
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.audiotrack),
                                      SizedBox(width: 8),
                                      Text('Audio Message'),
                                      Icon(Icons.play_arrow),
                                    ],
                                  ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: isCurrentUser ? 8 : 0,
                          left: !isCurrentUser ? 8 : 0),
                      child: Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text(
                            TimeUtils.formatTimestamp(message.timestamp),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black38),
                          ),
                          if (message.isEdited) ...[
                            const SizedBox(width: 7),
                            const Text('Edited',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black38)),
                          ],
                          const SizedBox(width: 7),
                          if (isCurrentUser)
                            Text(
                              message.isRead
                                  ? "Read"
                                  : (message.status == "Sent"
                                      ? "Sent"
                                      : "Pending"),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black38),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
