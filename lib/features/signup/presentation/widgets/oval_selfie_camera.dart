// lib/features/onboarding/presentation/widgets/oval_selfie_camera.dart
//
// Full-screen front-camera capture with an oval framing guide (matches the
// "round/oval selfie" requirement). Manual shutter + retake/use-photo
// confirm step. Push it and await a File back:
//
//   final file = await Navigator.of(context).push<File>(
//     MaterialPageRoute(builder: (_) => const OvalSelfieCameraPage()),
//   );
//
// Optional upgrade: add `google_mlkit_face_detection` to auto-fire the
// shutter once a face is detected centered inside the oval, instead of
// requiring a manual tap. Not included here to keep this self-contained.

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

const _kAccentBlue = Color(0xFF3B4EF5);

class OvalSelfieCameraPage extends StatefulWidget {
  const OvalSelfieCameraPage({super.key});

  @override
  State<OvalSelfieCameraPage> createState() => _OvalSelfieCameraPageState();
}

class _OvalSelfieCameraPageState extends State<OvalSelfieCameraPage> {
  CameraController? _controller;
  Future<void>? _initFuture;
  XFile? _captured;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller =
          CameraController(front, ResolutionPreset.high, enableAudio: false);
      _initFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not access the camera: $e');
    }
  }

  Future<void> _capture() async {
    if (_controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await _controller!.takePicture();
      setState(() => _captured = file);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _retake() => setState(() => _captured = null);

  void _usePhoto() {
    if (_captured != null) Navigator.of(context).pop(File(_captured!.path));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _error != null
            ? _buildError()
            : (_captured != null ? _buildPreview() : _buildCameraView()),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            _controller == null) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        final size = MediaQuery.of(context).size;
        final ovalWidth = size.width * 0.72;
        final ovalHeight = ovalWidth * 1.3;

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize?.height ?? size.width,
                    height:
                        _controller!.value.previewSize?.width ?? size.height,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: _OvalHoleClipper(
                  ovalWidth: ovalWidth, ovalHeight: ovalHeight),
              child: Container(color: Colors.black.withOpacity(0.55)),
            ),
            Center(
              child: Container(
                width: ovalWidth,
                height: ovalHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.elliptical(ovalWidth / 2, ovalHeight / 2)),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Positioned(
              top: 28,
              left: 0,
              right: 0,
              child: Text(
                'Fit your face inside the oval',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _capture,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: _capturing
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreview() {
    final size = MediaQuery.of(context).size;
    final ovalWidth = size.width * 0.72;
    final ovalHeight = ovalWidth * 1.3;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: ClipPath(
            clipper: _OvalClipper(),
            child: SizedBox(
              width: ovalWidth,
              height: ovalHeight,
              child: Image.file(File(_captured!.path), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 24,
          right: 24,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _retake,
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _usePhoto,
                  child: const Text('Use photo'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _OvalHoleClipper extends CustomClipper<Path> {
  final double ovalWidth;
  final double ovalHeight;
  _OvalHoleClipper({required this.ovalWidth, required this.ovalHeight});

  @override
  Path getClip(Size size) {
    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final center = Offset(size.width / 2, size.height / 2);
    final hole = Path()
      ..addOval(Rect.fromCenter(
          center: center, width: ovalWidth, height: ovalHeight));
    return Path.combine(PathOperation.difference, outer, hole);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
