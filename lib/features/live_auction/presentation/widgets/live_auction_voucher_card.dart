// lib/features/live_auction/presentation/widgets/live_auction_voucher_card.dart

import 'package:flutter/material.dart';

/// Shows a promo popup telling the dealer how many auctions are live
/// right now and inviting them to start bidding. Call [maybeShow] from
/// wherever you decide it's the right moment (see AuctionHomePage) —
/// this widget itself has no opinion on *when*, only *what it looks
/// like* and *what happens when tapped*.
class LiveAuctionVoucherCard extends StatelessWidget {
  final int liveCount;
  final VoidCallback onViewAuctions;

  const LiveAuctionVoucherCard({
    super.key,
    required this.liveCount,
    required this.onViewAuctions,
  });

  /// Convenience wrapper around showDialog — call this instead of
  /// constructing the widget directly.
  static Future<void> maybeShow({
    required BuildContext context,
    required int liveCount,
    required VoidCallback onViewAuctions,
  }) {
    if (liveCount <= 0) return Future.value();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LiveAuctionVoucherCard(
        liveCount: liveCount,
        onViewAuctions: onViewAuctions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.gavel_rounded,
                  color: Color(0xFF6200EE), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              liveCount == 1
                  ? '1 live auction is open now'
                  : '$liveCount live auctions are open now',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Place your bid before time runs out.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewAuctions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View live auctions',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not now',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
