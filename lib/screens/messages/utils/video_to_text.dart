//From ChatGPT

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VideoTranscriptionWidget extends StatefulWidget {
  final String videoFilePath;

  VideoTranscriptionWidget({required this.videoFilePath});

  @override
  _VideoTranscriptionWidgetState createState() =>
      _VideoTranscriptionWidgetState();
}

class _VideoTranscriptionWidgetState extends State<VideoTranscriptionWidget> {
  late stt.SpeechToText _speech;
  late FlutterSoundPlayer _player;
  String _transcription = 'Press the button to start transcription';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _player = FlutterSoundPlayer();
  }

  Future<void> _extractAudioAndTranscribe() async {
    final outputAudioFilePath = '/path/to/output/audio.aac'; // Specify the output audio file path

    // Extract audio using flutter_sound
    await _player.startPlayer(
      fromURI: widget.videoFilePath,
      codec: Codec.aacADTS,
      whenFinished: () {
        print('Audio extraction finished.');
      },
    );
    
    // Save the extracted audio to a file
    await _player.toFile(outputAudioFilePath);

    if (File(outputAudioFilePath).existsSync()) {
      final audioContent = File(outputAudioFilePath).readAsStringSync();
      _startTranscription(audioContent);
    } else {
      setState(() {
        _transcription = 'Error extracting audio';
      });
    }
  }

  Future<void> _startTranscription(String audioContent) async {
    final isAvailable = await _speech.initialize(
      onStatus: (status) {
        print('Speech-to-Text Status: $status');
      },
      onError: (errorNotification) {
        print('Speech-to-Text Error: $errorNotification');
      },
    );

    if (isAvailable) {
      final result = await _speech.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        },
      );

      if (!result.recognized) {
        setState(() {
          _transcription = 'Speech-to-text failed';
        });
      }
    } else {
      setState(() {
        _transcription = 'Speech-to-text not available';
      });
    }
  }

  @override
  void dispose() {
    _player.closeAudioSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_transcription),
        ElevatedButton(
          onPressed: _extractAudioAndTranscribe,
          child: Text('Start Transcription'),
        ),
      ],
    );
  }
}
