import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraModal extends StatefulWidget {
  final Function(String) onVideoRecorded;

  const CameraModal({Key? key, required this.onVideoRecorded})
      : super(key: key);

  @override
  State<CameraModal> createState() => _CameraModalState();
}

class _CameraModalState extends State<CameraModal> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
  late Timer _timer;
  int _timerSeconds = 30;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _timer.cancel(); // Cancel the timer to prevent memory leaks
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
      setState(() {
        _isRecording = true;
        _startTimer();
      });
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
        _recordVideo(); // Stop recording when timer reaches 0
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
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
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 3, color: Colors.white),
                    borderRadius: BorderRadius.circular(100)),
                onPressed: () => _recordVideo(),
              ),
            ),
            if (_isRecording)
              Positioned(
                top: 50,
                child: SizedBox(
                  width: 150, // Constant width for the background container
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color:
                          Colors.black.withOpacity(0.3), // Adjust opacity here
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_timerSeconds',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _timerSeconds <= 5 ? Colors.red : Colors.white,
                        fontSize: 72, // Adjust font size here
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
    _cameraController = CameraController(front, ResolutionPreset.low);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }
}
