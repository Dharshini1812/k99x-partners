// lib/features/live_auction/presentation/widgets/auction_card.dart

import 'dart:async';
import 'package:dealer/core/helper/feedback_helper.dart';
import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/glitter_shimmer_button.dart';
import 'package:dealer/features/live_auction/presentation/widgets/place_bid_sheet.dart';
import 'package:dealer/features/live_auction/presentation/widgets/quote_price_sheet.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';
import 'package:dealer/features/trial/presentation/widgets/trial_blocked_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LiveAuctionCard extends ConsumerStatefulWidget {
  final LiveAuctionModel vehicle;
  final bool isUpcoming;
  final bool isQuotePrice;
  final bool isBidHistory;
  final String? statusBadge;

  const LiveAuctionCard({
    super.key,
    required this.vehicle,
    this.isUpcoming = false,
    this.isQuotePrice = false,
    this.isBidHistory = false,
    this.statusBadge,
  });

  @override
  ConsumerState<LiveAuctionCard> createState() => _LiveAuctionCardState();
}

class _LiveAuctionCardState extends ConsumerState<LiveAuctionCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isBidHistory) {
      _computeRemaining();
      _timer = Timer.periodic(
          const Duration(seconds: 1), (_) => _computeRemaining());
    }
  }

  @override
  void didUpdateWidget(covariant LiveAuctionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isBidHistory &&
        oldWidget.vehicle.auctionCloseDt != widget.vehicle.auctionCloseDt) {
      _computeRemaining();
    }
  }

  void _computeRemaining() {
    final closeDt =
        widget.vehicle.extendedEndTime ?? widget.vehicle.auctionCloseDt;
    final parsed = AuctionDateHelper.parseAuctionDate(closeDt);
    if (parsed == null) {
      if (mounted) setState(() => _ended = true);
      return;
    }
    final diff = parsed.difference(DateTime.now());
    if (!mounted) return;
    setState(() {
      if (diff.isNegative) {
        _ended = true;
        _remaining = Duration.zero;
        _timer?.cancel();
      } else {
        _ended = false;
        _remaining = diff;
      }
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatPrice(int? amount) {
    if (amount == null) return '₹--';
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0 && posFromRight % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₹$buf';
  }

  String _formatBidDate(String? dtStr) {
    if (dtStr == null || dtStr.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.tryParse(dtStr.replaceFirst(' ', 'T'));
      if (parsed != null) {
        return DateFormat('dd MMM, yyyy').format(parsed);
      }
    } catch (_) {}
    return dtStr;
  }

  /// Resolves the current bid:
  /// 1. Prioritizes the live `highestBid` from BidActivityData (if matching vehicleId)
  /// 2. Falls back to the latest amount in vehicle.bids
  double? _currentBidAmount(LiveAuctionModel v) {
    final liveActivity = ref.watch(bidActivityNotifierProvider).maybeWhen(
          data: (data) =>
              (data.auction?.vehicleId == v.vehicleId) ? data : null,
          orElse: () => null,
        );

    if (liveActivity?.highestBid != null && liveActivity!.highestBid! > 0) {
      return liveActivity.highestBid!.toDouble();
    }

    final bids = v.bids;
    if (bids == null || bids.isEmpty) return null;

    final sorted = List<BidsModel>.from(bids)
      ..sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
    return sorted.first.amount;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleWatchlistToggle(bool isCurrentlyWatchlisted) async {
    final targetId = widget.vehicle.vehicleId ?? '';
    if (targetId.isEmpty) return;

    final willAdd = !isCurrentlyWatchlisted;
    final success = await ref
        .read(watchlistUpdateNotifierProvider.notifier)
        .updateWatchlist(vehicleId: targetId, add: willAdd);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            willAdd
                ? 'Vehicle added to your watchlist'
                : 'Vehicle removed from your watchlist',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor:
              willAdd ? const Color(0xFF10B981) : const Color(0xFF334155),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update watchlist'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openBidSheet(BidSheetMode mode) async {
    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      ref
          .read(bidActivityNotifierProvider.notifier)
          .fetchBidActivity(vehicleId);
    }

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceBidSheet(vehicle: widget.vehicle, mode: mode),
    );

    if (result != null && mounted) {
      await FeedbackHelper.success();
      if (vehicleId != null && vehicleId.isNotEmpty) {
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId, silent: true);
      }
    }
  }

  Future<void> _openQuotePriceSheet() async {
    final user = ref.read(dLogic).user;
    final trial = ref.read(trialLogic);

    if (user == null && trial.isTrialSession) {
      showTrialBlockedDialog(context, ref, expired: trial.isTrialExpired);
      return;
    }

    await showModalBottomSheet<num>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuotePriceSheet(vehicle: widget.vehicle),
    );
  }

  void _openImageSliderDialog(BuildContext context) async {
    FeedbackHelper.tap();

    final vehicleId = widget.vehicle.vehicleId?.trim() ?? '';
    if (vehicleId.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (_) => const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      ),
    );

    final subscription = ref.listenManual(
      vehicleDetailProvider,
      (previous, next) {},
    );

    List<String> finalUrls = [];

    try {
      await ref
          .read(vehicleDetailProvider.notifier)
          .fetchVehicleDetail(vehicleId);

      final detailState = ref.read(vehicleDetailProvider);
      finalUrls = detailState.maybeWhen(
        loaded: (response) {
          final list = response.data?.images ?? [];
          return list
              .map((img) => img.url?.trim() ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
        },
        orElse: () => <String>[],
      );
    } catch (e) {
      debugPrint("Error fetching vehicle detail images: $e");
    } finally {
      subscription.close();

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!mounted) return;

    if (finalUrls.isEmpty && widget.vehicle.imageUrl?.url?.isNotEmpty == true) {
      finalUrls = [widget.vehicle.imageUrl!.url!];
    }

    if (finalUrls.isNotEmpty) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (ctx) => _ImageGallerySliderDialog(images: finalUrls),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images available for this vehicle')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final title = [v.mfgYear, v.make, v.model, v.variant]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' ');
    final location = [v.cityName, shortState(v.stateName)]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    final specs = [
      v.fuel,
      v.kmsDriven != null ? '${v.kmsDriven}K km' : null,
      v.ownerCount != null
          ? '${v.ownerCount} owner${v.ownerCount == 1 ? '' : 's'}'
          : null,
    ].where((e) => e != null).join(' • ');
    final currentBid = _currentBidAmount(v);

    final bool isUpcoming = widget.isUpcoming ||
        (v.status ?? '').trim().toUpperCase() == 'UPCOMING';

    final bool isQuote = widget.isQuotePrice ||
        v.mode == 3 ||
        (v.status ?? '').trim().toUpperCase() == 'QUOTE';

    final isWinning = widget.statusBadge?.toUpperCase() == 'WINNING';
    final isOutbid = widget.statusBadge?.toUpperCase() == 'OUTBID';

    final watchlistState = ref.watch(watchlistNotifierProvider);
    final isWatchlisted = watchlistState.maybeWhen(
      data: (items) =>
          items.any((item) => item.vehicle?.vehicleId == v.vehicleId),
      orElse: () => false,
    );

    final double? startingPriceDouble = v.startingprice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinning
              ? const Color(0xFF10B981).withOpacity(0.5)
              : (isOutbid
                  ? const Color(0xFFEF4444).withOpacity(0.4)
                  : Colors.grey.shade200),
          width: (isWinning || isOutbid) ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _openImageSliderDialog(context),
                child: _AuctionThumbnail(imageUrl: v.imageUrl?.url ?? ''),
              ),

              // Status Badge Tile (WINNING / OUTBID)
              if (widget.statusBadge != null && widget.statusBadge!.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isWinning
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWinning
                              ? Icons.emoji_events_rounded
                              : Icons.trending_down_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.statusBadge!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      isWatchlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWatchlisted
                          ? const Color(0xFFE74C3C)
                          : Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _handleWatchlistToggle(isWatchlisted),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87.withOpacity(.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AUX${v.lotNo ?? ""}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87.withOpacity(.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    v.regno ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if ((v.imageUrls?.length ?? 0) > 1)
                Positioned(
                  bottom: 10,
                  left: 65,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_outlined,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${v.imageUrls!.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location.isNotEmpty ? location : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Text(
                  title.isNotEmpty ? title : 'Vehicle',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (specs.isNotEmpty)
                  Text(
                    specs,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),

                // ── LENDER & PRICE ROW ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleCase(v.lenderName),
                      style: const TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          if (widget.isBidHistory) ...[
                            const TextSpan(
                              text: 'Bid Amount: ',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: currentBid != null
                                  ? _formatPrice(currentBid.toInt())
                                  : (v.winningBid != null
                                      ? _formatPrice(v.winningBid!.toInt())
                                      : '₹--'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                fontSize: 14.5,
                              ),
                            ),
                          ] else ...[
                            TextSpan(
                              text: isQuote
                                  ? 'Base price (To): '
                                  : 'Base price: ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: _formatPrice(v.basePrice?.toInt()),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── SECOND ROW: BID DATE (HISTORY) VS TIMER (ACTIVE) ──
                if (widget.isBidHistory) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatBidDate(v.auctionCloseDt ??
                            v.auctionStartDt ??
                            v.createdDt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isUpcoming
                                ? Icons.schedule_rounded
                                : Icons.timer_outlined,
                            size: 18,
                            color: isUpcoming
                                ? const Color(0xFF6200EE)
                                : (_ended ? Colors.red : Colors.black87),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUpcoming
                                ? 'Upcoming'
                                : (_ended ? 'Ended' : _fmt(_remaining)),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isUpcoming
                                  ? const Color(0xFF6200EE)
                                  : (_ended ? Colors.red : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      if (!isQuote)
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                            children: [
                              const TextSpan(
                                text: 'Current Bid: ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: currentBid != null
                                    ? _formatPrice(currentBid.toInt())
                                    : 'No bids yet',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          startingPriceDouble != null
                              ? 'Start price (From): ${_formatPrice(startingPriceDouble.toInt())}'
                              : 'Start price (From): ${_formatPrice(((v.basePrice ?? 0) * 0.75).round())}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Action Buttons (Only for active auctions)
                  if (isUpcoming) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 16, color: Color(0xFF6B7280)),
                            SizedBox(width: 6),
                            Text(
                              'Auction Starts Soon',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (isQuote) ...[
                    GlitterShimmerButton(
                      onPressed: _ended ? null : _openQuotePriceSheet,
                      text: 'Quote price',
                      icon: Icons.request_quote_rounded,
                      gradientColors: const [
                        Color(0xFFD97706),
                        Color(0xFFF59E0B),
                        Color(0xFFB45309),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _ended
                                ? null
                                : () => _openBidSheet(BidSheetMode.autobid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3E5F5),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Auto bid',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlitterShimmerButton(
                            onPressed: _ended
                                ? null
                                : () => _openBidSheet(BidSheetMode.bid),
                            text: 'Bid',
                            icon: Icons.gavel_rounded,
                            gradientColors: const [
                              Color(0xFF4F46E5),
                              Color(0xFF7C3AED),
                              Color(0xFFDB2777),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionThumbnail extends StatelessWidget {
  final String? imageUrl;
  const _AuctionThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (!hasImage) {
      return Container(
        height: 190,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_car_rounded,
            size: 40,
            color: Color(0xFFBFC2CC),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        imageUrl!,
        height: 280,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 280,
            color: const Color(0xFFF3F4F6),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 280,
          width: double.infinity,
          color: const Color(0xFFF3F4F6),
          child: const Center(
            child: Icon(
              Icons.directions_car_rounded,
              size: 40,
              color: Color(0xFFBFC2CC),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageGallerySliderDialog extends StatefulWidget {
  final List<String> images;
  const _ImageGallerySliderDialog({required this.images});

  @override
  State<_ImageGallerySliderDialog> createState() =>
      _ImageGallerySliderDialogState();
}

class _ImageGallerySliderDialogState extends State<_ImageGallerySliderDialog> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 500,
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: total,
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        itemBuilder: (context, index) {
                          return InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 3.5,
                            child: Image.network(
                              widget.images[index],
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, prog) {
                                if (prog == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white38,
                                  size: 48,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (total > 1 && _currentIndex > 0)
                        Positioned(
                          left: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 16),
                              onPressed: _prevPage,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      if (total > 1 && _currentIndex < total - 1)
                        Positioned(
                          right: 5,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white, size: 16),
                              onPressed: _nextPage,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Text(
                  '${_currentIndex + 1} /$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -12,
            right: -8,
            child: CircleAvatar(
              backgroundColor: Colors.black87,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
