import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/models/MessageModel.dart';
import 'package:flutter_chat_boilerplate/core/models/userModel.dart';
import 'package:flutter_chat_boilerplate/core/services/local_storage_service.dart';
import 'package:flutter_chat_boilerplate/core/services/message_service.dart';
import 'package:flutter_chat_boilerplate/core/services/typing_service.dart';
import 'package:flutter_chat_boilerplate/core/services/user_status_service.dart';
import 'package:get/get.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  // Services
  final MessageService _messageService = MessageService();
  final TypingService _typingService = TypingService();
  final UserStatusService _userStatusService = UserStatusService();
  final Map<String, dynamic> args = Get.arguments;
  final user = Get.arguments['user']  as UserModel;
  final from = Get.arguments['from'];
  // User
  // final UserModel user = Get.arguments as UserModel;
  late String currentUserId;
  late String otherUserId;

  // States
  RxBool isTyping = false.obs;
  RxBool isOtherUserOnline = false.obs;
  Rx<DateTime?> lastSeen = Rx<DateTime?>(null);
  RxBool isRecording = false.obs;
  RxBool isCurrentUser = false.obs;
  bool isChatScreenVisible = false;

  // Text & Messages
  final TextEditingController textController = TextEditingController();
  var messageList = <MessageModel>[].obs;
  var messageText = ''.obs;
  RxSet<MessageModel> selectedMessages = <MessageModel>{}.obs;
  Rxn<MessageModel> selectedMessage = Rxn<MessageModel>();
  RxBool isEditing = false.obs;
  String? editingMessageId;
 RxBool isLoading = false.obs;
  // Lifecycle
  @override
  Future<void> onInit() async {
    super.onInit();
    currentUserId = await LocalStorageService.getUserId()??"";
    print("📦 Retrieved userId: $from");

    isLoading .value= true;
   print(" user.uid.toString()${ user.uid.toString()}");
    initChat(currentUserId, user.uid.toString());
    isChatScreenVisible = true;

    WidgetsBinding.instance.addObserver(this);
    _userStatusService.setUserOnlineStatus(currentUserId: currentUserId, isOnline: true);
    listenToUserStatus();
    listenToTypingStatus(currentUserId: currentUserId, otherUserId: otherUserId);
    print("otherUserId${otherUserId}");
    markMessagesAsRead();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isOnline = state == AppLifecycleState.resumed;
    _userStatusService.setUserOnlineStatus(currentUserId: currentUserId, isOnline: isOnline);
  }

  @override
  void onClose() {
    super.onClose();
    isChatScreenVisible = false;
    // _userStatusService.setUserOnlineStatus(currentUserId: currentUserId, isOnline: false);
    // WidgetsBinding.instance.removeObserver(this);
  }

  // Initialization
  void initChat(String currentId, String otherId) {
    currentUserId = currentId;
    otherUserId = otherId;

    _messageService.getMessages(currentUserId, otherUserId).listen((messages) {
      messageList.value = messages;

      Future.delayed(Duration(milliseconds: 500), () {
        markMessagesAsRead();
      });
      isLoading .value= false;
    });
  }

  // Typing
  void updateTypingStatus() {
    _typingService.updateTypingStatus(
      senderId: currentUserId,
      receiverId: otherUserId,
      isTyping: textController.text.isNotEmpty,
    );
  }

  void listenToTypingStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    _typingService
        .getTypingStatus(currentUserId: currentUserId, otherUserId: otherUserId)
        .listen((typing) => isTyping.value = typing);
  }

  // User Online Status
  void listenToUserStatus() {
    _userStatusService.getUserOnlineStatus(otherUserId: otherUserId).listen((status) {
      isOtherUserOnline.value = status['isOnline'] ?? false;
      lastSeen.value = (status['lastSeen'] as Timestamp?)?.toDate();
    });
  }

  // Message Actions
  Future<void> sendMessage() async {
    if (textController.text.isEmpty) return;
print("function::::::::::::");
    final message = MessageModel(
      senderId: currentUserId,
      receiverId: otherUserId,
      text: textController.text,
      timestamp: DateTime.now(),
      isRead: false,
      isEdited: false,
      messageType: 'Text',
      status: "Sent",
    );

    textController.clear();
    await _messageService.sendMessage(message);
    updateTypingStatus();
  }

  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      await _messageService.updateMessage(
        senderId: currentUserId,
        receiverId: otherUserId,
        messageId: messageId,
        newText: newText,
      );
      selectedMessage.value = null;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteSelectedMessages() async {
    if (selectedMessages.isEmpty) return;

    try {
      final messageIds = selectedMessages.map((msg) => msg.id!).toList();

      await _messageService.deleteMessages(
        senderId: currentUserId,
        receiverId: otherUserId,
        messageIds: messageIds,
      );

      selectedMessages.clear();
      selectedMessage.value = null;

      Get.snackbar("Success", "Selected messages deleted.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  Future<void> deleteMessagesForCurrentUser() async {
    if (selectedMessages.isEmpty) return;

    try {
      final messageIds = selectedMessages.map((msg) => msg.id!).toList();

      await _messageService.deleteMessagesForCurrentUser(
        senderId: currentUserId,
  receiverId: otherUserId,
        messageIds: messageIds,
      );

      selectedMessages.clear();
      selectedMessage.value = null;
print("success");
      Get.snackbar("Deleted", "Messages deleted from your side.");
    } catch (e) {
      print("E:::::::${e}");
      Get.snackbar("Error", e.toString());
    }
  }


  // Read Receipts
  void markMessagesAsRead() async {
    await Future.delayed(Duration(milliseconds: 300));

    for (var message in messageList) {
      if (!message.isRead &&
          message.senderId == otherUserId &&
          isChatScreenVisible) {
        await _messageService.markMessageAsRead(
          currentUserId,
          otherUserId,
          message.id!,
        );
      }
    }
  }

  // Message Selection
  void toggleSelection(MessageModel message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }

    selectedMessage.value = selectedMessages.length == 1
        ? selectedMessages.first
        : null;
  }

  // Recording Toggle
  void toggleRecording() {
    isRecording.value = !isRecording.value;
    if (isRecording.value) {
      // Start recording
    } else {
      // Stop & upload recording
    }
  }

  // Dummy Method
  // void markAsRead(String messageId) async {
  //   final deviceId = await getDeviceId();
  //   await FirebaseFirestore.instance
  //       .collection('messages')
  //       .doc(messageId)
  //       .update({'readBy.$deviceId': true});
  // }
}
