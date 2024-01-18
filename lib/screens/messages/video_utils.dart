import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoUtils {
  static Size calculateVideoDimensions(
      VideoPlayerController controller, double maxWidth, double maxHeight) {
    double aspectRatio = controller.value.aspectRatio;

    double videoWidth = min(maxWidth, controller.value.size.width);
    double videoHeight = min(maxHeight, videoWidth / aspectRatio);

    bool heightLimiting = false;
    bool widthLimiting = false;

    // If the video is in portrait mode, reduce the width further to ensure the height fits within the rectangle
    if (controller.value.size.aspectRatio < 1.0) {
      videoWidth = min(videoWidth, videoHeight * aspectRatio);
      videoHeight = videoWidth / aspectRatio;
    }

    if(videoWidth > maxWidth) heightLimiting = true;
    if(videoHeight > maxHeight) widthLimiting = true;

    return Size(videoWidth, videoHeight);
  }
}
