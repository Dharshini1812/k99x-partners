// lib/features/live_auction/presentation/widgets/live_auction_card_skeleton.dart

import 'package:flutter/material.dart';

class LiveAuctionCardSkeleton extends StatelessWidget {
  const LiveAuctionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 190,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 90, height: 10),
                const SizedBox(height: 8),
                _bar(width: 180, height: 16),
                const SizedBox(height: 8),
                _bar(width: 140, height: 12),
                const SizedBox(height: 10),
                _bar(width: 100, height: 12),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bar(width: 70, height: 14),
                    _bar(width: 90, height: 14),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _bar(width: double.infinity, height: 36)),
                    const SizedBox(width: 10),
                    Expanded(child: _bar(width: double.infinity, height: 36)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class LiveAuctionListSkeleton extends StatelessWidget {
  final int itemCount;
  const LiveAuctionListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const LiveAuctionCardSkeleton(),
    );
  }
}
