import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

//import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/models/local_message.dart';

import 'package:flutter_ai_chat/screens/messages/widgets/video_thumbnail.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/video_dialog.dart';

/*class VideoMessage extends StatelessWidget {
  final LocalMessage? message;

  const VideoMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    debugPrint('Im in VideoMessage');
    //if (message != null) {
    String videoMessageFilePath = message!.filePath.toString();
    debugPrint('Im in VideoMessage $videoMessageFilePath');
    //}

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45, // 45% of total width
      child: VideoThumbnail(filePath: videoMessageFilePath),
    );
  }
}*/

class VideoMessage extends StatelessWidget {
  final LocalMessage? message;

  const VideoMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeVideoController(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          VideoPlayerController controller =
              snapshot.data as VideoPlayerController;
          return Stack(
            children: [
              VideoThumbnail(controller: controller),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => VideoDialog(controller: controller),
                  );
                },
                child: Text("Open Video"),
              ),
            ],
          );
        } else {
          return CircularProgressIndicator(); // or other loading indicator
        }
      },
    );
  }

  Future<VideoPlayerController> initializeVideoController() async {
    VideoPlayerController controller =
        VideoPlayerController.file(File(message!.filePath.toString()));
    await controller.initialize();
    return controller;
  }
}
