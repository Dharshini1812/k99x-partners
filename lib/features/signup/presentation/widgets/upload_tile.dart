// lib/features/onboarding/presentation/widgets/upload_tile.dart
//
// One reusable box for every "Click selfie" / "Upload Aadhaar front" style
// tile. Empty state: dashed border + a tinted icon badge, so it reads as
// "tap to add" rather than a plain disabled-looking box. Filled state:
// the photo with a small retake button bottom-right.

import 'dart:io';
import 'package:flutter/material.dart';

const _kAccentBlue = Color(0xFF4C3DE0);
const _kAccentTint = Color(0xFFEEEDFE);
const _kFaintBg = Color(0xFFF7F8FC);
const _kDashColor = Color(0xFFC7C9DC);
const _kBorder = Color(0xFFE7E8F0);
const _kLabelGrey = Color(0xFF8A8FA6);

class UploadTile extends StatelessWidget {
  final String label;
  final bool required;
  final File? file;
  final IconData icon;
  final String actionText;
  final VoidCallback onTap;
  final VoidCallback? onRetake;
  final bool isCircular;

  const UploadTile({
    super.key,
    required this.label,
    required this.icon,
    required this.actionText,
    required this.onTap,
    this.required = false,
    this.file,
    this.onRetake,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: _kLabelGrey)),
            if (required) ...[
              const SizedBox(width: 3),
              const Text('*',
                  style: TextStyle(color: Color(0xFFE24B4A), fontSize: 12)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: file == null ? onTap : null,
          child: file == null
              ? _EmptyTile(
                  icon: icon, actionText: actionText, isCircular: isCircular)
              : _FilledTile(
                  file: file!, onRetake: onRetake, isCircular: isCircular),
        ),
      ],
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final IconData icon;
  final String actionText;
  final bool isCircular;
  const _EmptyTile(
      {required this.icon, required this.actionText, required this.isCircular});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: _kDashColor,
        radius: isCircular ? 999 : 14,
      ),
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: _kFaintBg,
          borderRadius: BorderRadius.circular(isCircular ? 999 : 14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: _kAccentTint, shape: BoxShape.circle),
              child: Icon(icon, color: _kAccentBlue, size: 18),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                actionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _kAccentBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledTile extends StatelessWidget {
  final File file;
  final VoidCallback? onRetake;
  final bool isCircular;
  const _FilledTile(
      {required this.file, this.onRetake, required this.isCircular});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCircular ? 999 : 14),
        border: Border.all(color: _kBorder),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: onRetake,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.refresh, color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

/// Even, evenly-spaced dashed rounded-rect border — signals "tap to add"
/// without pulling in an extra package for one visual detail.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 5,
    this.dashGap = 4,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius > size.height / 2 ? size.height / 2 : radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
