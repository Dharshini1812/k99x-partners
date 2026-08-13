import 'package:intl/intl.dart';

String formatDate(dynamic timestamp) {
  if (timestamp == null) return '-';

  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd/MM/yyyy').format(date);
}

String? toTitleCase(String? input) {
  if (input == null) return null;
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final first = trimmed[0].toUpperCase();
  final rest = trimmed.length > 1 ? trimmed.substring(1).toLowerCase() : '';
  return '$first$rest';
}

String? convertCondition(String? text) {
  switch (text) {
    case '5.0':
      return 'Excellent';
    case '4.0':
      return 'Good';
    case '3.0':
      return 'Average';
    case '2.0':
      return 'Poor';
    case '1.0':
      return 'Bad';
  }
  return '';
}

String getFlutterImageUrl(String url) {
  if (url.isEmpty) return url;

  // Convert Cloudinary AVIF delivery to WebP
  if (url.contains('res.cloudinary.com') && url.contains('/image/upload/')) {
    return url.replaceFirst(
      '/image/upload/',
      '/image/upload/f_webp/',
    );
  }

  return url;
}
