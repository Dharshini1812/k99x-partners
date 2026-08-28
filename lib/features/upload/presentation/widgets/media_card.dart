// lib/features/upload/presentation/widgets/media_card.dart

import 'dart:io';
import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isVideo;
  final String? path;
  final VoidCallback onCapture;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;

  final bool isUploading;
  final bool isUploadError;
  final String? uploadErrorMessage;
  final VoidCallback? onRetryUpload;

  const MediaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isVideo,
    required this.path,
    required this.onCapture,
    required this.onUpload,
    this.onRemove,
    this.isUploading = false,
    this.isUploadError = false,
    this.uploadErrorMessage,
    this.onRetryUpload,
  });

  void _showRetakeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    isVideo ? Icons.videocam_rounded : Icons.camera_alt_rounded,
                    color: UploadColors.primary,
                  ),
                  title: Text(
                    isVideo ? 'Record Video (Camera)' : 'Take Photo (Camera)',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onCapture();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  title: Text(
                    isVideo
                        ? 'Choose Video from Gallery'
                        : 'Choose Photo from Gallery',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onUpload();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = path != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UploadColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploadError ? UploadColors.danger : UploadColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: UploadText.label),
          const SizedBox(height: 10),
          _Preview(path: path, isVideo: isVideo, isUploading: isUploading),
          const SizedBox(height: 10),
          if (!hasMedia)
            _CaptureActions(
              isVideo: isVideo,
              onCapture: onCapture,
              onUpload: onUpload,
            )
          else
            _EditActions(
              onRetake: () => _showRetakeOptions(context),
              onRemove: onRemove,
              isUploading: isUploading,
            ),
          if (isUploadError) ...[
            const SizedBox(height: 8),
            _UploadErrorBanner(
              message: uploadErrorMessage ?? 'Upload failed',
              onRetry: onRetryUpload,
            ),
          ],
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final String? path;
  final bool isVideo;
  final bool isUploading;

  const _Preview({
    required this.path,
    required this.isVideo,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = path != null;

    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: hasMedia ? Colors.black : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(10),
          border: hasMedia ? null : Border.all(color: UploadColors.border),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasMedia) _MediaThumbnail(path: path!, isVideo: isVideo),
            if (!hasMedia)
              Center(
                child: Icon(
                  isVideo ? Icons.videocam_outlined : Icons.camera_alt_outlined,
                  color: UploadColors.textMuted,
                  size: 28,
                ),
              ),
            if (isUploading)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final String path;
  final bool isVideo;

  const _MediaThumbnail({required this.path, required this.isVideo});

  bool get _isRemote =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPreviewDialog(context),
      child: isVideo
          ? const Center(
              child:
                  Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
            )
          : (_isRemote
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child:
                        Icon(Icons.check_circle, color: Colors.white, size: 32),
                  ),
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child:
                        Icon(Icons.check_circle, color: Colors.white, size: 32),
                  ),
                )),
    );
  }

  void _openPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _MediaPreviewDialog(
        path: path,
        isVideo: isVideo,
        isRemote: _isRemote,
      ),
    );
  }
}

class _MediaPreviewDialog extends StatefulWidget {
  final String path;
  final bool isVideo;
  final bool isRemote;

  const _MediaPreviewDialog({
    required this.path,
    required this.isVideo,
    required this.isRemote,
  });

  @override
  State<_MediaPreviewDialog> createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<_MediaPreviewDialog> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = widget.isRemote
        ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
        : VideoPlayerController.file(File(widget.path));
    try {
      await controller.initialize();
      controller.setLooping(true);
      await controller.play();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            child: widget.isVideo ? _buildVideo() : _buildImage(),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: widget.isRemote
          ? Image.network(widget.path, fit: BoxFit.contain)
          : Image.file(File(widget.path), fit: BoxFit.contain),
    );
  }

  Widget _buildVideo() {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.white, size: 40),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller!),
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Container(color: Colors.transparent),
            ),
            VideoProgressIndicator(_controller!, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}

class _CaptureActions extends StatelessWidget {
  final bool isVideo;
  final VoidCallback onCapture;
  final VoidCallback onUpload;

  const _CaptureActions({
    required this.isVideo,
    required this.onCapture,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCapture,
            style: ElevatedButton.styleFrom(
              backgroundColor: UploadColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isVideo ? 'Capture Video' : 'Capture Photo'),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onUpload,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isVideo ? 'Upload Video' : 'Upload Photo',
            style: const TextStyle(
              fontSize: 12,
              color: UploadColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditActions extends StatelessWidget {
  final VoidCallback onRetake;
  final VoidCallback? onRemove;
  final bool isUploading;

  const _EditActions({
    required this.onRetake,
    required this.onRemove,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isUploading ? null : onRetake,
            style: OutlinedButton.styleFrom(
              foregroundColor: UploadColors.primary,
              side: const BorderSide(color: UploadColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retake'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: isUploading ? null : onRemove,
            style: OutlinedButton.styleFrom(
              foregroundColor: UploadColors.danger,
              side: const BorderSide(color: UploadColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Remove'),
          ),
        ),
      ],
    );
  }
}

class _UploadErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _UploadErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: UploadColors.danger, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 11, color: UploadColors.danger),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: UploadColors.danger,
              ),
            ),
          ),
      ],
    );
  }
}
