import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

class CameraModal extends StatefulWidget {
  final Function(String) onVideoRecorded;

  const CameraModal({super.key, required this.onVideoRecorded});

  @override
  State<CameraModal> createState() => _CameraModalState();
}

class _CameraModalState extends State<CameraModal> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      //debugPrint('I have a file $file.path');
      // Pass the file path back to the caller
      // Use the callback to pass the file path back to the parent
      widget.onVideoRecorded(file.path);
      Navigator.pop(context);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                foregroundColor: _isRecording ? Colors.white : Colors.red,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                shape: RoundedRectangleBorder(side: BorderSide(width: 3,color: Colors.white),borderRadius: BorderRadius.circular(100)),
                onPressed: () => _recordVideo(),
              ),
            ),
          ],
        ),
      );
    }
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }
}
