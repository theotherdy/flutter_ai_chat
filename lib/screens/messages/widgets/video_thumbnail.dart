//Adapted from: https://github.com/bettercoding-dev/flutter-video/blob/master/lib/video_page.dart
//but developed with a lot of help from ChatGPT
//import 'dart:io';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/screens/messages/video_utils.dart';
//import 'package:flutter_ai_chat/screens/messages/widgets/video_dialog.dart';

class VideoThumbnail extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoThumbnail({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.45;
    double aspectRatio =
        16 / 9; // Desired aspect ratio - always a landscape shape

    double rectWidth = maxWidth;
    double rectHeight = rectWidth / aspectRatio;

    double videoWidth =
        VideoUtils.calculateVideoDimensions(controller, rectWidth, rectHeight)
            .width;
    double videoHeight =
        VideoUtils.calculateVideoDimensions(controller, rectWidth, rectHeight)
            .height;

    return Container(
      width: rectWidth,
      height: rectHeight,
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: videoWidth,
            height: videoHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: VideoPlayer(controller),
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

class VideoThumbnail extends StatefulWidget {
  final LocalMessage? message;

  //final String filePath;

  const VideoThumbnail({super.key, required this.message});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showVideoModal(context);
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _VideoPlayer(
                filePath: widget.message!.filePath.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: _VideoPlayer(filePath: widget.message!.filePath.toString()),
        );
      },
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final String filePath;

  _VideoPlayer({required this.filePath});

  @override
  __VideoPlayerState createState() => __VideoPlayerState();
}

class __VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.file(
      File(widget.filePath),
    );

    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);

    _controller.addListener(() {
      if (!_controller.value.isPlaying && mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.45;
    double aspectRatio = 16 / 9; // Desired aspect ratio

    // Calculate dimensions for the rectangle
    double rectWidth = maxWidth;
    double rectHeight = rectWidth / aspectRatio;

    // Determine the video orientation
    bool isVideoPortrait = _controller.value.size.aspectRatio < 1.0;

    // Calculate dimensions for the video inside the rectangle
    double videoWidth = min(rectWidth, _controller.value.size.width);
    double videoHeight = videoWidth / _controller.value.aspectRatio;

    // If the video is in portrait mode, reduce the width further to ensure the height fits within the rectangle
    if (isVideoPortrait) {
      videoWidth = min(videoWidth, rectHeight * _controller.value.aspectRatio);
      videoHeight = videoWidth / _controller.value.aspectRatio;
    }

    double adjustedWidth = videoWidth;
    double adjustedHeight = videoHeight;

    return StatefulBuilder(
      builder: (context, setState) {
        // Check if the widget is showing in the chat
        bool isInChat = context.widget.toStringShort() == '_VideoPlayer';

        return Container(
          width: rectWidth,
          height: rectHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: adjustedWidth,
                height: adjustedHeight,
                child: _controller.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: VideoPlayer(_controller),
                      )
                    : Container(),
              ),
              // Show controls only in the dialog
              if (!isInChat)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: (_isPlaying &&
                              _controller != null &&
                              _controller.value.isInitialized)
                          ? () {
                              _controller.pause();
                              setState(() {
                                _isPlaying = false;
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: (!_isPlaying &&
                              _controller != null &&
                              _controller.value.isInitialized)
                          ? () {
                              _controller.play();
                              setState(() {
                                _isPlaying = true;
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: (_controller != null &&
                              _controller.value.isInitialized &&
                              _controller.value.position != Duration.zero)
                          ? () {
                              _controller.seekTo(Duration.zero);
                              _controller.play();
                              setState(() {
                                _isPlaying = true;
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: (_controller != null &&
                              _controller.value.isInitialized)
                          ? () {
                              _controller.pause();
                              Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}*/

//Replacement from ChatGPT

/*void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Video Player Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display video thumbnail
              VideoThumbnail(filePath: 'path_to_your_video.mp4'),
              // ... Add more widgets as needed
            ],
          ),
        ),
      ),
    ),
  );
}*/
