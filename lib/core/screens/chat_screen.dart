import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/models/MessageModel.dart';
import 'package:flutter_chat_boilerplate/core/services/audio_player_services.dart';
import 'package:flutter_chat_boilerplate/core/services/chat_services.dart';
import 'package:flutter_chat_boilerplate/core/services/voice_note_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatService _chatService = ChatService();
  final VoiceNoteService _voiceNoteService = VoiceNoteService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  bool _isRecording = false;
  String? _recordedAudioPath;

  @override
  void dispose() {
    _audioPlayerService.dispose();
    super.dispose();
  }

  // Send text message
  void _sendMessage(String text) async {
    if (text.isNotEmpty) {
      final message = MessageModel(
        isEdited: true,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: 'qwM1L8NEHRTdHkKsJUFJ7BxMalF3',
        receiverId: 'tXT7qobFiCVyG24eJSTVoYQdUII2',
        timestamp: DateTime.now(),
        isRead: false,
        messageType: 'text',
      );

      try {
        await _chatService.sendMessage(message);
        setState(() {
          _messages.add({'type': 'text', 'content': text});
          _controller.clear();
        });
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  // Start recording audio message
  void _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    await _voiceNoteService.startRecording();
  }

  // Stop recording and upload the file to Firebase
  void _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    final audioPath = await _voiceNoteService.stopRecording();
    if (audioPath != null) {
      setState(() {
        _recordedAudioPath = audioPath;
      });
      _sendAudioToFirebase(audioPath);
    }
  }

  // Upload audio file to Firebase
  Future<void> _sendAudioToFirebase(String audioPath) async {
    try {
      final file = File(audioPath);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('voice_notes/$fileName.m4a');

      await ref.putFile(file);
      final fileUrl = await ref.getDownloadURL();

      final message = MessageModel(
        isEdited: true,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: fileUrl,  // Sending the URL of the audio file
        senderId: 'qwM1L8NEHRTdHkKsJUFJ7BxMalF3',
        receiverId: 'tXT7qobFiCVyG24eJSTVoYQdUII2',
        timestamp: DateTime.now(),
        isRead: false,
        messageType: 'audio', // Message type is audio
      );

      await _chatService.sendMessage(message);
      setState(() {
        _messages.add({'type': 'audio', 'content': fileUrl});
      });
    } catch (e) {
      print("Error sending audio message: $e");
    }
  }

  // Play audio message
  void _playAudio(String audioUrl) {
    _audioPlayerService.playAudio(audioUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Audio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message['type'] == 'text') {
                  return ListTile(
                    title: Text(message['content']),
                    tileColor: Colors.grey[200],
                  );
                } else if (message['type'] == 'audio') {
                  return ListTile(
                    title: Text('Audio Message'),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        if (message['content'] != null) {
                          _playAudio(message['content']);
                        }
                      },
                    ),
                    tileColor: Colors.blue[50],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Text input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Text input for typing messages
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                // Send button for text messages
                IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_controller.text);
                    }
                ),
              ],
            ),
          ),

          // Audio recording controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Record button for audio messages
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
