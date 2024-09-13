import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  final Function(String filePath) onRecordingComplete;

  const AudioRecorder({Key? key, required this.onRecordingComplete})
      : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final Record _recorder = Record();
  String? _audioPath;
  bool _isRecording = false;

  Future<void> _startRecording() async {
    // Request permission to access the microphone
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      //debugPrint("Microphone permission granted");
      Directory tempDir = await getTemporaryDirectory();
      // Generate a unique file name using a timestamp
      String fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _audioPath = '${tempDir.path}/$fileName';

      await _recorder.start(
        path: _audioPath,
        encoder: AudioEncoder.aacLc, // AAC format for m4a
        bitRate: 128000,
        samplingRate: 44100,
      );

      setState(() {
        _isRecording = true;
      });
    } else if (status.isDenied) {
      //debugPrint('Microphone permission denied');
    } else if (status.isPermanentlyDenied) {
      //debugPrint("Microphone permission permanently denied");
      openAppSettings(); // Opens the app settings for the user to manually allow the microphone permission
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() {
      _isRecording = false;
    });

    if (_audioPath != null) {
      widget.onRecordingComplete(_audioPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          onPressed: _isRecording ? _stopRecording : _startRecording,
        ),
        Text(_isRecording ? 'Recording...' : 'Tap to record'),
      ],
    );
  }
}
