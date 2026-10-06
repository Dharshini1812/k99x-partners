// lib/features/my_listings/presentation/pages/vehicle_card_skeleton.dart

import 'package:flutter/material.dart';

/// Placeholder shaped like CarInspectionCard's collapsed summary row —
/// same container, same proportions (72x72 thumbnail, title/subtitle
/// lines, three rating chips + expand button) — so the list doesn't
/// visibly jump once real data replaces it. Same plain gray-box style
/// as VehicleDetailSkeleton / DashboardPage's _StatGridSkeleton
/// elsewhere in this app, no shimmer package.
class VehicleCardSkeleton extends StatelessWidget {
  const VehicleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 72, height: 72, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: double.infinity, height: 13),
                      const SizedBox(height: 8),
                      _box(width: 140, height: 11),
                      const SizedBox(height: 8),
                      _box(width: 110, height: 11),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _box(width: 20, height: 8),
                    const SizedBox(height: 4),
                    _box(width: 36, height: 38, radius: 7),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                    child: _box(width: double.infinity, height: 26, radius: 6)),
                const SizedBox(width: 5),
                Expanded(
                    child: _box(width: double.infinity, height: 26, radius: 6)),
                const SizedBox(width: 5),
                Expanded(
                    child: _box(width: double.infinity, height: 26, radius: 6)),
                const SizedBox(width: 5),
                _box(width: 60, height: 26, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(
      {required double width, required double height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A full-list version — N skeleton cards stacked with the same
/// spacing the real lists use (10px gaps).
class VehicleCardSkeletonList extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;

  const VehicleCardSkeletonList({
    super.key,
    this.count = 4,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (int i = 0; i < count; i++) ...[
            const VehicleCardSkeleton(),
            if (i != count - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
