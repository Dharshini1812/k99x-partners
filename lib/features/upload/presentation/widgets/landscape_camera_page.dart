// lib/features/upload/presentation/widgets/landscape_camera_page.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandscapeCameraPage extends StatefulWidget {
  final bool isVideo;
  final String title;

  const LandscapeCameraPage({
    super.key,
    required this.isVideo,
    this.title = 'Vehicle Capture',
  });

  @override
  State<LandscapeCameraPage> createState() => _LandscapeCameraPageState();
}

class _LandscapeCameraPageState extends State<LandscapeCameraPage> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    // Lock strictly to landscape while on this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final rearCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: widget.isVideo,
    );

    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInit = true);
  }

  @override
  void dispose() {
    // Reset orientation back to portrait when exiting
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final file = await _controller!.takePicture();
    if (mounted) Navigator.pop(context, file.path);
  }

  Future<void> _toggleVideo() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      if (mounted) Navigator.pop(context, file.path);
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fullscreen camera preview
          Center(
            child: CameraPreview(_controller!),
          ),

          // Header title & back button
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Optional car silhouette alignment frame
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Action capture button (positioned on the right thumb edge)
          Positioned(
            right: 30,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: widget.isVideo ? _toggleVideo : _takePhoto,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isVideo && _isRecording
                        ? Colors.red
                        : Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: widget.isVideo
                        ? Icon(
                            _isRecording
                                ? Icons.stop_rounded
                                : Icons.fiber_manual_record_rounded,
                            color: _isRecording ? Colors.white : Colors.red,
                            size: 36,
                          )
                        : const Icon(Icons.camera_alt,
                            color: Colors.black87, size: 30),
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
