// lib/features/upload/presentation/widgets/review_grid.dart
//
// Two-column label/value grid used on the review step.

import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';

class ReviewGrid extends StatelessWidget {
  final List<(String, String)> pairs;

  const ReviewGrid({super.key, required this.pairs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 14,
      children: pairs.map((p) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.$1, style: UploadText.label),
              const SizedBox(height: 2),
              Text(p.$2, style: UploadText.value),
            ],
          ),
        );
      }).toList(),
    );
  }
}
