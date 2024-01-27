import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_ai_chat/screens/messages/utils/video_utils.dart';

class VideoPlayerControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback play;
  final VoidCallback pause;
  final VoidCallback replay;
  final VoidCallback close;

  const VideoPlayerControls({super.key, 
    required this.controller,
    required this.play,
    required this.pause,
    required this.replay,
    required this.close,
  });

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  late VideoPlayerController _controller;
  late VoidCallback _listener;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration currentPosition = _controller.value.position;
    Duration totalDuration = _controller.value.duration;

    print('Current Position: $currentPosition');
    print('Total Duration: $totalDuration');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: (currentPosition == Duration.zero || _isPaused)
              ? () {
                  setState(() {
                    _isPaused = false;
                  });
                  widget.play();
                }
              : null,
          child: const Icon(Icons.play_arrow),
        ),
        ElevatedButton(
          onPressed: (currentPosition < totalDuration && !_isPaused)
              ? () {
                  setState(() {
                    _isPaused = true;
                  });
                  widget.pause();
                }
              : null,
          child: const Icon(Icons.pause),
        ),
        ElevatedButton(
          onPressed: currentPosition > Duration.zero ? widget.replay : null,
          child: const Icon(Icons.replay),
        ),
        ElevatedButton(
          onPressed: widget.close,
          child: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class VideoDialog extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double dialogWidth = screenWidth * 0.9;
    double dialogHeight =
        screenHeight * 0.9; //dialogWidth / (16 / 9); // Aspect ratio 16:9

    return Dialog(
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: _VideoPlayer(
            controller: controller,
            containerWidth: dialogWidth,
            containerHeight: dialogHeight),
      ),
    );
  }
}

class _VideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final double containerWidth;
  final double containerHeight;

  const _VideoPlayer({
    required this.controller,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;

    Size videoDimensions = VideoUtils.calculateVideoDimensions(
      controller,
      containerWidth,
      containerHeight,
    );

    return SizedBox(
      width: videoDimensions.width,
      height: videoDimensions.height,
      child: Stack(
        //mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: SizedBox(
            width: videoDimensions.width,
            height: videoDimensions.height,
            child: controller.value.isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: VideoPlayer(controller),
                  )
                : Container(),
          )),
          VideoPlayerControls(
            controller: controller,
            play: () {
              controller.play();
              isPlaying = true;
            },
            pause: () {
              controller.pause();
              isPlaying = false;
            },
            replay: () {
              controller.seekTo(Duration.zero);
              controller.play();
              isPlaying = true;
            },
            close: () {
              controller.pause();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
