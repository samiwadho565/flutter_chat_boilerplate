import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_boilerplate/core/services/audio_player_services.dart'; // For handling platform-specific errors.

class AudioPlayerWidget extends StatefulWidget {
  final String audioFilePath; // Path to the audio file.

  const AudioPlayerWidget({Key? key, required this.audioFilePath}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  bool isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;
  bool isLoading = false; // For showing loading spinner.
  String errorMessage = ''; // For showing any error messages.

  @override
  void initState() {
    super.initState();

    // Listen to position changes.
    _audioPlayerService.audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position.inMilliseconds.toDouble();
      });
    });

    // Listen to duration changes.
    _audioPlayerService.audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration.inMilliseconds.toDouble();
      });
    });

    // Listen to audio completion.
    _audioPlayerService.audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _currentPosition = 0.0; // Reset position when audio completes.
      });
    });

    // Handling errors.
    // _audioPlayerService.audioPlayer.onPlayerError.listen((message) {
    //   setState(() {
    //     errorMessage = message ?? 'An unknown error occurred while playing audio.';
    //     isLoading = false; // Stop loading if error occurs.
    //   });
    // });
  }

  // Toggle play/pause.
  void toggleAudio() async {
    if (isPlaying) {
      await _audioPlayerService.pauseAudio();
    } else {
      setState(() {
        isLoading = true;
        errorMessage = ''; // Clear previous error.
      });
      try {
        await _audioPlayerService.playAudio(widget.audioFilePath);
      } catch (e) {
        setState(() {
          errorMessage = 'Error occurred: $e';
        });
      }
    }

    setState(() {
      isPlaying = !isPlaying;
      isLoading = false; // Stop loading spinner after play/pause.
    });
  }

  // Seek to a specific position.
  void seekTo(double position) async {
    try {
      await _audioPlayerService.seekAudio(position.toInt());
    } catch (e) {
      setState(() {
        errorMessage = 'Error occurred while seeking: $e';
      });
    }
  }

  @override
  void dispose() {
    _audioPlayerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display loading spinner if audio is loading.
        if (isLoading) CircularProgressIndicator(),

        // Display error message if there's any.
        if (errorMessage.isNotEmpty)
          Text(
            errorMessage,
            style: TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),

        // Play/Pause button
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: toggleAudio,
        ),

        // Slider for seeking audio.
        Slider(
          value: _currentPosition,
          min: 0.0,
          max: _totalDuration,
          onChanged: (value) {
            setState(() {
              _currentPosition = value;
            });
            seekTo(value); // Seek to the new position.
          },
        ),

        // Duration display
        Text(
          "${_formatDuration(Duration(milliseconds: _currentPosition.toInt()))} / ${_formatDuration(Duration(milliseconds: _totalDuration.toInt()))}",
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Format duration in mm:ss format.
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
