import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VoiceNoteService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordFilePath;

  /// Check microphone permission
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start recording voice note
  Future<void> startRecording() async {
    final hasMicPermission = await hasPermission();
    if (!hasMicPermission) {
      throw Exception('Microphone permission not granted');
    }

    final directory = await getTemporaryDirectory();
    final fileName = '${const Uuid().v4()}.m4a';
    _recordFilePath = '${directory.path}/$fileName';

    // Ensure the _recordFilePath is not null
    if (_recordFilePath == null) {
      throw Exception('Failed to generate file path');
    }

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordFilePath!, // assert non-null by using '!' operator
    );
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path ?? _recordFilePath;
  }

  /// Cancel recording and delete the file if it exists
  Future<void> cancelRecording() async {
    await _recorder.cancel();
    if (_recordFilePath != null) {
      final file = File(_recordFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _recordFilePath = null;
  }

  /// Dispose recorder when done
  void dispose() {
    _recorder.dispose();
  }
}
