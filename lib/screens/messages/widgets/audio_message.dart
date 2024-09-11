import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/models/local_message.dart';

class AudioMessage extends StatefulWidget {
  final LocalMessage message;
  final AudioPlayer audioPlayer;

  const AudioMessage({
    Key? key,
    required this.message,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  bool _isPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    widget.audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    widget.audioPlayer.durationStream.listen((duration) {
      setState(() {
        _audioDuration = duration ?? Duration.zero;
      });
    });

    widget.audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  @override
  void dispose() {
    widget.audioPlayer.stop();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await widget.audioPlayer.pause();
    } else {
      if (widget.audioPlayer.processingState != ProcessingState.ready) {
        await widget.audioPlayer.setFilePath(widget.message.filePath!);
      }
      await widget.audioPlayer.play();
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
        color: kPrimaryColor.withOpacity(
            widget.message.role == LocalMessageRole.user ? 1 : 0.1),
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
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _audioDuration.inSeconds.toDouble(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white54,
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await widget.audioPlayer.seek(position);
                  },
                ),
              ),
              Text(
                '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Text(
            widget.message.text ?? '', // Transcription or text
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}