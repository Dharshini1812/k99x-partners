// lib/features/live_auction/presentation/widgets/place_bid_sheet.dart

import 'dart:async';
import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/glitter_shimmer_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BidSheetMode { bid, autobid }

class _DetailItem {
  final String label;
  final String value;
  final bool full;
  const _DetailItem(this.label, this.value, {this.full = false});
}

class PlaceBidSheet extends ConsumerStatefulWidget {
  final LiveAuctionModel vehicle;
  final int? currentDealerId;
  final BidSheetMode mode;
  final String? eventId;
  final int? lenderId;
  final int? initialRank;
  final int? initialTotalBids;

  const PlaceBidSheet({
    super.key,
    required this.vehicle,
    this.currentDealerId,
    this.mode = BidSheetMode.bid,
    this.eventId,
    this.lenderId,
    this.initialRank,
    this.initialTotalBids,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends ConsumerState<PlaceBidSheet> {
  late final TextEditingController _amountController;
  late int _amount;

  Timer? _timer;
  Duration? _remaining;
  bool _ended = false;

  int? _lastServerRank;

  static const int _minIncrement = 1000;

  bool get _isAutobidMode => widget.mode == BidSheetMode.autobid;

  @override
  void initState() {
    super.initState();

    _lastServerRank = widget.initialRank ?? widget.vehicle.rank;

    // Starting price is strictly from vehicle
    final int startingPrice =
        (widget.vehicle.startingprice ?? widget.vehicle.basePrice ?? 0).toInt();

    // Text box holds Starting Price
    _amount = startingPrice;
    _amountController = TextEditingController(text: '$_amount');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _computeRemaining();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _computeRemaining(),
      );

      final vehicleId = widget.vehicle.vehicleId;
      if (vehicleId != null && vehicleId.isNotEmpty) {
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId);

        final socket = ref.read(liveBidSocketProvider);
        socket.connect(
          onMessage: (data) async {
            if (!mounted) return;
            await ref
                .read(bidActivityNotifierProvider.notifier)
                .fetchBidActivity(vehicleId, silent: true);
            ref.invalidate(cardBidActivityProvider(vehicleId));
            if (mounted) setState(() {});
          },
        );
        socket.subscribe(vehicleId);
      }
    });
  }

  @override
  void dispose() {
    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      ref.read(liveBidSocketProvider).unsubscribe(vehicleId);
    }

    _timer?.cancel();
    _amountController.dispose();
    ref.read(bidActivityNotifierProvider.notifier).stopPolling();
    super.dispose();
  }

  DateTime? _resolveTargetEndTime(BidActivityData? liveActivity) {
    final auction = liveActivity?.auction;

    final ext = auction?.extendedEndTime;
    if (ext != null && ext > 0) {
      return AuctionDateHelper.parseAuctionDate(ext);
    }

    final end = auction?.endTime;
    if (end != null && end > 0) {
      return AuctionDateHelper.parseAuctionDate(end);
    }

    final vExt = widget.vehicle.extendedEndTime;
    if (vExt != null && vExt.trim().isNotEmpty) {
      final parsed = AuctionDateHelper.parseAuctionDate(vExt);
      if (parsed != null) return parsed;
    }

    return AuctionDateHelper.parseAuctionDate(widget.vehicle.auctionCloseDt);
  }

  void _computeRemaining() {
    if (!mounted) return;

    final liveActivity = ref.read(bidActivityNotifierProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );

    final target = _resolveTargetEndTime(liveActivity);

    if (target == null) {
      if (liveActivity != null) {
        setState(() => _ended = true);
      }
      return;
    }

    final diff = target.difference(DateTime.now());
    setState(() {
      if (diff.isNegative) {
        _ended = true;
        _remaining = Duration.zero;
      } else {
        _ended = false;
        _remaining = diff;
      }
    });
  }

  String _fmtTimer(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  List<BidsModel> _withKnownBidderNames(List<BidsModel> liveBids) {
    final staticBids = widget.vehicle.bids ?? const [];
    final nameById = <int, String>{
      for (final b in staticBids)
        if (b.id != null && (b.bidderName ?? '').trim().isNotEmpty)
          b.id!: b.bidderName!,
    };
    final nameByDealerId = <String, String>{
      for (final b in staticBids)
        if (b.dealerId != null && (b.bidderName ?? '').trim().isNotEmpty)
          b.dealerId.toString(): b.bidderName!,
    };

    for (final bid in liveBids) {
      if ((bid.bidderName ?? '').trim().isNotEmpty) continue;
      final byId = bid.id != null ? nameById[bid.id] : null;
      final byDealer =
          bid.dealerId != null ? nameByDealerId[bid.dealerId.toString()] : null;
      bid.bidderName = byId ?? byDealer;
    }
    return liveBids;
  }

  List<BidsModel> _getSortedBids(BidActivityData? liveActivity) {
    final liveBids = liveActivity?.bids;
    final bids = List<BidsModel>.from(liveBids != null
        ? _withKnownBidderNames(liveBids)
        : (widget.vehicle.bids ?? const []));
    bids.sort((a, b) {
      final ta = DateTime.tryParse((a.timestamp ?? '').replaceFirst(' ', 'T'));
      final tb = DateTime.tryParse((b.timestamp ?? '').replaceFirst(' ', 'T'));
      if (ta == null || tb == null) return 0;
      return tb.compareTo(ta);
    });
    return bids;
  }

  double? _bestAmountForDealer(
      List<BidsModel> sortedBids, String? dealerIdStr) {
    if (dealerIdStr == null || dealerIdStr.isEmpty) return null;
    double? best;
    for (final b in sortedBids) {
      if (b.dealerId?.toString() != dealerIdStr) continue;
      final amt = b.amount ?? 0;
      if (best == null || amt > best) best = amt;
    }
    return best;
  }

  int _liveRankForDealer(List<BidsModel> sortedBids, String? dealerIdStr) {
    if (dealerIdStr == null || dealerIdStr.isEmpty) {
      return _lastServerRank ?? widget.initialRank ?? 0;
    }
    final myBest = _bestAmountForDealer(sortedBids, dealerIdStr) ?? 0;
    if (myBest == 0 && _lastServerRank != null) return _lastServerRank!;

    final bestPerDealer = <String, double>{};
    for (final b in sortedBids) {
      final id = b.dealerId?.toString();
      if (id == null) continue;
      final amt = b.amount ?? 0;
      if (!bestPerDealer.containsKey(id) || amt > bestPerDealer[id]!) {
        bestPerDealer[id] = amt;
      }
    }
    final higher = bestPerDealer.values.where((v) => v > myBest).length;
    return higher + 1;
  }

  String? get _resolvedCurrentDealerId {
    final uid = widget.currentDealerId ?? ref.read(dLogic).user?.userId;
    return uid?.toString();
  }

  int _suggestedStartAmount(
      BidActivityData? liveActivity, List<BidsModel> sortedBids) {
    final topBid = sortedBids.isNotEmpty ? sortedBids.first : null;
    final top = (liveActivity?.highestBid ?? topBid?.amount)?.toInt();
    final start =
        (widget.vehicle.startingprice ?? widget.vehicle.basePrice ?? 0).toInt();

    if (top != null && top > 0) {
      return top + _minIncrement;
    }
    return start;
  }

  void _onAmountChanged(String v) {
    final parsed = int.tryParse(v.replaceAll(',', ''));
    setState(() => _amount = parsed ?? 0);
  }

  String _formatAmount(num amount) {
    final s = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0 && posFromRight % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₹$buf';
  }

  Future<void> _showResultDialog({
    required bool success,
    required String title,
    required String message,
    int? rank,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          color: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          size: 44,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563)),
            ),
            if (rank != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: rank == 1
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rank == 1
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rank == 1
                          ? Icons.emoji_events_rounded
                          : Icons.trending_down_rounded,
                      size: 16,
                      color: rank == 1
                          ? const Color(0xFF065F46)
                          : const Color(0xFF991B1B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rank #$rank ${rank == 1 ? "(Winning)" : "(Outbid)"}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: rank == 1
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    success ? const Color(0xFF10B981) : const Color(0xFF3F51E8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBid(int minStart, List<BidsModel> sortedBids) async {
    final liveActivity = ref.read(bidActivityNotifierProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );
    final isAutobidRunning = (liveActivity?.autobid?.active == true) &&
        ((liveActivity?.autobid?.maxBidAmount ?? 0) > 0);

    if (isAutobidRunning || _ended) return;

    if (_amount < minStart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be at least ${_formatAmount(minStart)}'),
        ),
      );
      return;
    }

    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId == null || vehicleId.isEmpty) return;

    // Physical double-pulse vibration on button press
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.vibrate();
    });

    await ref.read(placeBidNotifier.notifier).placeBid(
          vehicleId: vehicleId,
          bidAmount: _amount.toDouble(),
        );

    if (!mounted) return;

    final result = ref.read(placeBidNotifier);
    result.when(
      initial: () {},
      loading: () {},
      data: (data) {
        final int resolvedRank = data.rank ??
            _liveRankForDealer(sortedBids, _resolvedCurrentDealerId);
        setState(() {
          _lastServerRank = resolvedRank;
        });

        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId, silent: true);
        ref.invalidate(cardBidActivityProvider(vehicleId));

        // Dialog opens silently without vibration or sound
        _showResultDialog(
          success: true,
          title: 'Bid Placed!',
          message:
              'Your bid of ${_formatAmount(_amount)} was placed successfully.',
          rank: resolvedRank,
        );
      },
      error: (msg) {
        String cleanMsg = msg;
        if (cleanMsg.contains('status code of 400')) {
          cleanMsg =
              'Bid could not be accepted. It must be higher than the current bid.';
        }
        _showResultDialog(
          success: false,
          title: 'Bid Failed',
          message: cleanMsg,
        );
      },
    );
  }

  Future<void> _submitAutobid(int minStart, AutobidInfo? myAutobid) async {
    if (_ended) return;

    if (_amount < minStart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Max bid must be at least ${_formatAmount(minStart)}'),
        ),
      );
      return;
    }

    final existingCeiling = myAutobid?.maxBidAmount;
    final isAutobidRunning =
        myAutobid?.active == true && (existingCeiling ?? 0) > 0;

    if (isAutobidRunning &&
        existingCeiling != null &&
        _amount <= existingCeiling) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Enter more than your current autobid ceiling of ${_formatAmount(existingCeiling)}'),
        ),
      );
      return;
    }

    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId == null || vehicleId.isEmpty) return;

    // Physical double-pulse vibration on button press
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.vibrate();
    });

    await ref.read(autoBidNotifier.notifier).enableAutoBid(
          vehicleId: vehicleId,
          maxBidAmount: _amount.toDouble(),
        );

    if (!mounted) return;

    final result = ref.read(autoBidNotifier);
    result.when(
      initial: () {},
      loading: () {},
      data: (data) {
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId, silent: true);
        ref.invalidate(cardBidActivityProvider(vehicleId));

        _showResultDialog(
          success: true,
          title: 'Autobid Enabled!',
          message: '${data.message}\nMax amount: ${_formatAmount(_amount)}',
        );
      },
      error: (msg) => _showResultDialog(
        success: false,
        title: 'Autobid Failed',
        message: msg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bidActivityNotifierProvider, (previous, next) {
      next.maybeWhen(
        data: (data) {
          _computeRemaining();
        },
        orElse: () {},
      );
    });

    final liveActivityState = ref.watch(bidActivityNotifierProvider);
    final BidActivityData? liveActivity = liveActivityState.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    final List<BidsModel> sortedBids = _getSortedBids(liveActivity);
    final int minStartAmount = _suggestedStartAmount(liveActivity, sortedBids);

    final currentDealerIdStr = _resolvedCurrentDealerId;
    final myHighestBid = _bestAmountForDealer(sortedBids, currentDealerIdStr);
    final userRank = _liveRankForDealer(sortedBids, currentDealerIdStr);
    final hasMyBid = myHighestBid != null || (userRank > 0);
    final isCurrentUserWinning = userRank == 1;

    final AutobidInfo? myAutobid = liveActivity?.autobid;
    final num? currentHighestBid = liveActivity?.highestBid ??
        (sortedBids.isNotEmpty ? sortedBids.first.amount : null);

    final bool isAutobidExhausted = () {
      final currentHigh = currentHighestBid ?? 0;
      final maxBid = myAutobid?.maxBidAmount ?? 0;
      if (maxBid <= 0) return false;
      return (currentHigh + _minIncrement) > maxBid && !isCurrentUserWinning;
    }();

    final bool isAutobidRunning =
        myAutobid != null && !isAutobidExhausted && myAutobid.active == true;

    final int totalBidsCount = sortedBids.isNotEmpty
        ? sortedBids.length
        : (widget.initialTotalBids ?? widget.vehicle.totalBids ?? 0);

    // Rule: totalBids == 0 -> "Current Price", totalBids > 0 -> "Current Bid"
    final bool hasBids = totalBidsCount > 0;
    final String sheetPriceTitle = hasBids ? 'Current Bid' : 'Current Price';
    final num sheetPriceValue = hasBids
        ? (currentHighestBid ??
            widget.vehicle.currentPrice ??
            widget.vehicle.basePrice ??
            0)
        : (widget.vehicle.currentPrice ?? widget.vehicle.basePrice ?? 0);

    final v = widget.vehicle;
    final title = [v.mfgYear, v.make, v.model, v.variant]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' ');

    final placeBidState = ref.watch(placeBidNotifier);
    final autoBidState = ref.watch(autoBidNotifier);

    final isPlacingBid =
        placeBidState.maybeWhen(loading: () => true, orElse: () => false);
    final isEnablingAutobid =
        autoBidState.maybeWhen(loading: () => true, orElse: () => false);

    final showBanner = isAutobidRunning || isAutobidExhausted;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    children: [
                      _header(title, liveActivity),
                      const SizedBox(height: 14),
                      _summaryTiles(
                        firstTileLabel: sheetPriceTitle,
                        firstTileValue: sheetPriceValue,
                        myBid: myHighestBid,
                        totalBidsCount: totalBidsCount,
                      ),
                      const SizedBox(height: 12),
                      _statusHeader(
                        sortedBids: sortedBids,
                        hasMyBid: hasMyBid,
                        userRank: userRank,
                        isCurrentUserWinning: isCurrentUserWinning,
                        isAutobidRunning: isAutobidRunning,
                        isAutobidExhausted: isAutobidExhausted,
                      ),
                      if (showBanner) ...[
                        const SizedBox(height: 12),
                        _autobidStatusBanner(isAutobidRunning, myAutobid),
                      ],
                      const SizedBox(height: 22),
                      _detailsCard(),
                    ],
                  ),
                ),
                _actionPanel(
                  minAmount: minStartAmount,
                  isPlacingBid: isPlacingBid,
                  isEnablingAutobid: isEnablingAutobid,
                  isAutobidRunning: isAutobidRunning,
                  onBid: () => _submitBid(minStartAmount, sortedBids),
                  onAutobid: () => _submitAutobid(minStartAmount, myAutobid),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(String title, BidActivityData? liveActivity) {
    final v = widget.vehicle;
    final imageUrl = (v.imageUrl?.url ?? '').trim();
    final regno = (v.regno ?? '').trim();
    final specs = [
      v.fuel,
      v.kmsDriven != null ? '${v.kmsDriven}K km' : null,
      v.ownerCount != null
          ? '${v.ownerCount} owner${v.ownerCount == 1 ? '' : 's'}'
          : null,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(' • ');

    const carIcon = Center(
      child: Icon(Icons.directions_car_rounded,
          size: 28, color: Color(0xFFBFC2CC)),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => carIcon,
                )
              : carIcon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isNotEmpty ? title : 'Vehicle',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (regno.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        regno,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (regno.isNotEmpty && specs.isNotEmpty)
                    const SizedBox(width: 8),
                  if (specs.isNotEmpty)
                    Flexible(
                      child: Text(
                        specs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _timerChip(liveActivity),
      ],
    );
  }

  Widget _timerChip(BidActivityData? liveActivity) {
    final rem = _remaining;
    final Color bg;
    final Color fg;
    final String label;

    if (_ended) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD64545);
      label = 'Ended';
    } else if (rem == null) {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
      label = '--:--:--';
    } else if (rem > Duration.zero && rem.inMinutes < 1) {
      bg = const Color(0xFFFFECEC);
      fg = const Color(0xFFDC2626);
      label = _fmtTimer(rem);
    } else if (rem.inMinutes < 60) {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB45309);
      label = _fmtTimer(rem);
    } else {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF111111);
      label = _fmtTimer(rem);
    }

    final isExtended = (liveActivity?.auction?.extendedEndTime ?? 0) > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExtended ? Icons.update_rounded : Icons.timer_outlined,
            size: 15,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTiles({
    required String firstTileLabel,
    required num? firstTileValue,
    required num? myBid,
    required int totalBidsCount,
  }) {
    final myBidLabel =
        (myBid != null && myBid > 0) ? _formatAmount(myBid) : 'No bids';
    final firstValueLabel = (firstTileValue != null && firstTileValue > 0)
        ? _formatAmount(firstTileValue)
        : '₹--';

    return Row(
      children: [
        _summaryTile(firstTileLabel, firstValueLabel),
        const SizedBox(width: 8),
        _summaryTile('Your Bid', myBidLabel),
        const SizedBox(width: 8),
        _summaryTile('Total Bids', '$totalBidsCount'),
      ],
    );
  }

  Widget _summaryTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEF0F2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusHeader({
    required List<BidsModel> sortedBids,
    required bool hasMyBid,
    required int userRank,
    required bool isCurrentUserWinning,
    required bool isAutobidRunning,
    required bool isAutobidExhausted,
  }) {
    final hasBids = sortedBids.isNotEmpty;
    final winning = hasMyBid && isCurrentUserWinning;

    final Color bg;
    final Color fg;
    final String label;
    final String sub;
    final IconData icon;

    if (!hasBids && !hasMyBid) {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
      label = 'No bids yet';
      sub = 'Be the first to bid on this vehicle';
      icon = Icons.hourglass_empty_rounded;
    } else if (winning) {
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      label = 'Winning';
      sub = isAutobidRunning
          ? 'Autobid active & highest bidder'
          : 'You\'re the highest bidder';
      icon = Icons.emoji_events_rounded;
    } else if (hasMyBid) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD64545);
      label = 'Outbid';
      sub = isAutobidExhausted
          ? 'Ceiling reached. Increase max bid to continue'
          : 'Another dealer is ahead — raise your bid';
      icon = Icons.trending_down_rounded;
    } else {
      final n = sortedBids.length;
      bg = const Color(0xFFEEF2FF);
      fg = const Color(0xFF3F51E8);
      label = 'Bidding live';
      sub = '$n bid${n == 1 ? '' : 's'} so far — place yours';
      icon = Icons.gavel_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: fg, fontWeight: FontWeight.w900, fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                      color: fg.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          if (hasMyBid && userRank > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rank #$userRank',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _autobidStatusBanner(bool isAutobidRunning, AutobidInfo? myAutobid) {
    final max = myAutobid?.maxBidAmount;
    final Color bg;
    final Color fg;
    final IconData icon;
    final String text;

    if (isAutobidRunning) {
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      icon = Icons.bolt_rounded;
      text = max != null
          ? 'Your autobid is active up to ${_formatAmount(max)}. Incremental bids will be placed automatically.'
          : 'Your autobid is active. Incremental bids will be placed automatically.';
    } else {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB45309);
      icon = Icons.info_outline_rounded;
      text = max != null
          ? 'Autobid stopped at ${_formatAmount(max)}. Next minimum step exceeds your limit.'
          : 'Autobid stopped. Increase your max limit to resume automated bidding.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 12, color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionPanel({
    required int minAmount,
    required bool isPlacingBid,
    required bool isEnablingAutobid,
    required bool isAutobidRunning,
    required VoidCallback onBid,
    required VoidCallback onAutobid,
  }) {
    final tooLow = _amount > 0 && _amount < minAmount;

    final helper = tooLow
        ? 'Enter at least ${_formatAmount(minAmount)}'
        : _isAutobidMode
            ? 'Minimum max ceiling: ${_formatAmount(minAmount)}'
            : 'Next valid bid: ${_formatAmount(minAmount)}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEEF0F2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _amountField(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                helper,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: tooLow ? FontWeight.w700 : FontWeight.w500,
                  color: tooLow
                      ? const Color(0xFFD64545)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            if (_isAutobidMode) ...[
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'System bids in ${_formatAmount(_minIncrement)} increments up to this ceiling.',
                  style:
                      const TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: _isAutobidMode
                  ? _autobidButton(isPlacingBid, isEnablingAutobid, onAutobid,
                      isAutobidRunning)
                  : _bidButton(
                      isPlacingBid, isEnablingAutobid, isAutobidRunning, onBid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bidButton(
    bool isPlacingBid,
    bool isEnablingAutobid,
    bool isAutobidRunning,
    VoidCallback onBid,
  ) {
    final bool isDisabled =
        _ended || isPlacingBid || isEnablingAutobid || isAutobidRunning;

    final label = _ended
        ? 'Auction ended'
        : isPlacingBid
            ? 'Placing...'
            : isAutobidRunning
                ? 'Auto bidding'
                : 'Bid now';

    return GlitterShimmerButton(
      onPressed: isDisabled ? null : onBid,
      text: label,
      icon: isPlacingBid ? null : Icons.gavel_rounded,
      gradientColors: const [
        Color(0xFF4F46E5),
        Color(0xFF7C3AED),
        Color(0xFFDB2777),
      ],
      sweepDuration: const Duration(milliseconds: 1400),
    );
  }

  Widget _autobidButton(
    bool isPlacingBid,
    bool isEnablingAutobid,
    VoidCallback onAutobid,
    bool isAutobidRunning,
  ) {
    final bool isDisabled = _ended || isPlacingBid || isEnablingAutobid;

    final label = _ended
        ? 'Auction ended'
        : isEnablingAutobid
            ? 'Enabling...'
            : isAutobidRunning
                ? 'Raise autobid ceiling'
                : 'Set autobid';

    return GlitterShimmerButton(
      onPressed: isDisabled ? null : onAutobid,
      text: label,
      icon: isEnablingAutobid
          ? null
          : (isAutobidRunning ? Icons.trending_up_rounded : Icons.bolt_rounded),
      gradientColors: const [
        Color(0xFF16A34A),
        Color(0xFF10B981),
        Color(0xFF0D9488),
      ],
      sweepDuration: const Duration(milliseconds: 1400),
    );
  }

  Widget _amountField() {
    return TextField(
      controller: _amountController,
      onChanged: _onAmountChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: _isAutobidMode ? 'Enter max ceiling amount' : 'Enter amount',
        prefixText: '₹ ',
        prefixStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F51E8), width: 1.6),
        ),
      ),
    );
  }

  Widget _detailsCard() {
    final v = widget.vehicle;
    final location = [v.cityName, shortState(v.stateName)]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');

    final vehicleItems = <_DetailItem>[
      _DetailItem('Make', v.make ?? '-'),
      _DetailItem('Model', v.model ?? '-'),
      _DetailItem('Variant', v.variant ?? '-'),
      _DetailItem('Year', v.mfgYear?.toString() ?? '-'),
      _DetailItem('Fuel', v.fuel ?? '-'),
      _DetailItem(
          'Kms driven', v.kmsDriven != null ? '${v.kmsDriven}K km' : '-'),
      _DetailItem(
          'Owners',
          v.ownerCount != null
              ? '${v.ownerCount} owner${v.ownerCount == 1 ? '' : 's'}'
              : '-'),
      _DetailItem('Reg. no', v.regno ?? '-'),
      _DetailItem('Category', v.categoryName?.toString() ?? '-', full: true),
    ];

    final auctionItems = <_DetailItem>[
      _DetailItem('Auction ID', v.vehicleId ?? '-', full: true),
      _DetailItem('Lender', titleCase(v.lenderName), full: true),
      _DetailItem('Location', location.isNotEmpty ? location : '-'),
      _DetailItem('Base price', _formatAmount(v.basePrice ?? 0)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Vehicle details'),
        const SizedBox(height: 8),
        _detailGrid(vehicleItems),
        const SizedBox(height: 18),
        _sectionLabel('Auction details'),
        const SizedBox(height: 8),
        _detailGrid(auctionItems),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111111)),
    );
  }

  Widget _detailGrid(List<_DetailItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0F2)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          final half = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: 14,
            children: [
              for (final item in items)
                SizedBox(
                  width: item.full ? constraints.maxWidth : half,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111)),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
