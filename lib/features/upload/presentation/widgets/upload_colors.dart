// lib/features/upload/presentation/theme/upload_ui.dart
//
// Single place for the colors/spacing used across the vehicle listing flow.
// Having one source of truth here is what makes the rest of the screens
// simple — no more repeated Colors.blue / Colors.red / magic hex codes.

import 'package:flutter/material.dart';

class UploadColors {
  UploadColors._();

  static const primary = Color(0xFF3366FF);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF1F9254);
  static const successBg = Color(0xFFE7F6EC);

  static const background = Color(0xFFF5F6FA);
  static const surface = Colors.white;
  static const border = Color(0xFFE4E7EC);

  static const textPrimary = Color(0xFF1D2433);
  static const textMuted = Color(0xFF8A8F98);
}

class UploadSpacing {
  UploadSpacing._();

  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
}

class UploadText {
  UploadText._();

  static const pageTitle = TextStyle(
    color: UploadColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const sectionTitle = TextStyle(
    color: UploadColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const stepTitle = TextStyle(
    color: UploadColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static const stepSubtitle = TextStyle(
    color: UploadColors.textMuted,
    fontSize: 13,
  );

  static const label = TextStyle(
    color: UploadColors.textMuted,
    fontSize: 11,
  );

  static const value = TextStyle(
    color: UploadColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
}
