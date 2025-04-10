import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Public getter for the AudioPlayer instance
  AudioPlayer get audioPlayer => _audioPlayer;

  /// Play the audio from the provided file path
  Future<void> playAudio(String filePath) async {
    try {
      await _audioPlayer.setSource(UrlSource(filePath));  // Use UrlSource for the file path
      await _audioPlayer.resume();  // Resume playback (if it's paused)
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  /// Pause the audio
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  /// Stop the audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  /// Seek to a specific position in the audio (in milliseconds)
  Future<void> seekAudio(int position) async {
    await _audioPlayer.seek(Duration(milliseconds: position));
  }

  /// Dispose of the audio player when done
  void dispose() {
    _audioPlayer.dispose();
  }
}
