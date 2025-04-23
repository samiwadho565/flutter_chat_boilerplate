import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/chat_screen_controller.dart';

class MessageOptionsBottomSheet {
  static void show(BuildContext context, ChatController controller) {
    final now = DateTime.now();
    final selectedMessages = controller.selectedMessages;
    if (selectedMessages.length == 1 && controller.isCurrentUser.value) {
      final message = selectedMessages.first;
      final isWithinOneHour = now.difference(message.timestamp).inMinutes <= 60;
      if (isWithinOneHour) {
        _showEditOptions(context, controller, message);
        return;
      }
    }

    _showBasicOptions(context, controller);
  }

  static void _showEditOptions(BuildContext context, ChatController controller, dynamic message) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              controller.textController.text = message.text; // Set text in input
              controller.isEditing.value = true; // Enable edit mode
              controller.editingMessageId = message.id; // Save message ID
            },

          ),
          _copyOption(),
          _forwardOption(),
          _deleteOption(controller),
        ],
      ),
    );
  }

  static void _showBasicOptions(BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          _copyOption(),
          _forwardOption(),
          _deleteOption(controller),
        ],
      ),
    );
  }

  static ListTile _copyOption() => const ListTile(
    leading: Icon(Icons.copy),
    title: Text('Copy'),
  );

  static ListTile _forwardOption() => const ListTile(
    leading: Icon(Icons.forward),
    title: Text('Forward'),
  );

  static ListTile _deleteOption(ChatController controller) => ListTile(
    leading: const Icon(Icons.delete),
    title: const Text('Delete'),
    onTap: () {
      print("tapped");
      controller.deleteMessagesForCurrentUser();
      Get.back();
    },
  );
}