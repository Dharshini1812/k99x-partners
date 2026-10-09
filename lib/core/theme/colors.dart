import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xff6161ff);
  static const Color accent = Color(0xFF8B2FC9);
  static const Color background = Color(0xFFF4F5FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color badgeBg = Color(0xFFF0F0F5);
  static const Color dotActive = Color(0xFF1B6CA8);
  static const Color dotInactive = Color(0xFFCDD0D8);
  static const Color loginColor = Color(0xff5b54e8);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: AppColors.background,
        ),
      );
}
