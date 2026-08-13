import 'dart:ui';

class OnboardingPageData {
  final String imagePath;
  final String badge;
  final String step;
  final String title;
  final String description;
  final Color themeColor;

  const OnboardingPageData({
    required this.imagePath,
    required this.badge,
    required this.step,
    required this.title,
    required this.description,
    required this.themeColor,
  });
}
