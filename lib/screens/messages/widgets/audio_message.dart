import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/models/local_message.dart';

class AudioMessage extends StatefulWidget {
  final LocalMessage message;
  //final AudioPlayer audioPlayer;

  const AudioMessage({
    Key? key,
    required this.message,
    //required this.audioPlayer,
  }) : super(key: key);

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  late AudioPlayer _audioPlayer; // Create a separate instance

  bool _isPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer(); // Initialize new player for each message

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _audioDuration = duration ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen to processing state to detect when audio finishes playing
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        setState(() {
          _currentPosition = Duration.zero; // Reset to zero
          _isPlaying = false; // Reset play button to pause state
        });
        _audioPlayer
            .seek(Duration.zero); // Optional: Ensure playback position is reset
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.processingState != ProcessingState.ready) {
        await _audioPlayer.setFilePath(widget.message.filePath!);
      }
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.75,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: widget.message!.role == LocalMessageRole.user
            ? kSecondaryColor // Light green for user
            : Colors.white, // White for assistant
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: kPrimaryColor,
                ),
                onPressed: _togglePlayPause,
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _audioDuration.inSeconds.toDouble(),
                  activeColor: Colors.white,
                  thumbColor: kPrimaryColor,
                  inactiveColor: Colors.white54,
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
              ),
              Text(
                '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          Text(
            widget.message.text ?? '', // Transcription or text
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
