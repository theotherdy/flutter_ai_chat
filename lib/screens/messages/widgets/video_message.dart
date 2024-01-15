import 'package:flutter/material.dart';

//import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/models/local_message.dart';

import 'package:flutter_ai_chat/screens/messages/widgets/video_player_wrapper.dart';

class VideoMessage extends StatelessWidget {
  final LocalMessage? message;

  const VideoMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    debugPrint('Im in VideoMessage');
    if (message != null) {
      String videoMessageFilePath = message!.filePath.toString();
      debugPrint('Im in VideoMessage $videoMessageFilePath');
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45, // 45% of total width
      child: VideoPlayerWrapper(message: message),
      /*child: AspectRatio(
          aspectRatio: 1.6, child: VideoPlayerWrapper(message: message)
          child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset("assets/images/Video Place Here.png"),
            ),
            Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 16,
                color: Colors.white,
              ),
            )
          ],
        ),*/
      //   ),
    );
  }
}
