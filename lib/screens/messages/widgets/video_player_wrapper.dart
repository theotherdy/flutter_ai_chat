//Adapted from: https://github.com/bettercoding-dev/flutter-video/blob/master/lib/video_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_ai_chat/models/local_message.dart';



class VideoPlayerWrapper extends StatefulWidget {
  LocalMessage? message;
  VideoPlayerWrapper({super.key, required this.message});  //don't forget to add this. before passed parameters!!!

  @override
  State<VideoPlayerWrapper> createState() => _VideoPlayerWrapperState();
}

class _VideoPlayerWrapperState extends State<VideoPlayerWrapper> {
  //

  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    String filePath;
    debugPrint('Im in _initVideoPLayer');
    debugPrint(widget.message!.filePath);
    if(widget.message != null && widget.message!.filePath.toString() != '') {
      filePath = widget.message!.filePath.toString();
      _videoPlayerController = VideoPlayerController.file(File(filePath));
      await _videoPlayerController.initialize();
    }
    
    //await _videoPlayerController.setLooping(true);
    //await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              debugPrint('do something with the file');
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }
}