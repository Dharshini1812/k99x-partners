// lib/features/live_auction/presentation/widgets/place_bid_sheet.dart

import 'dart:async';

import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
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
  const PlaceBidSheet({
    super.key,
    required this.vehicle,
    this.currentDealerId,
    this.mode = BidSheetMode.bid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends ConsumerState<PlaceBidSheet> {
  late final TextEditingController _amountController;
  late int _amount;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  static const int _minIncrement = 1000;

  bool get _isAutobidMode => widget.mode == BidSheetMode.autobid;

  @override
  void initState() {
    super.initState();
    final staticTop =
        (widget.vehicle.bids != null && widget.vehicle.bids!.isNotEmpty)
            ? (List<BidsModel>.from(widget.vehicle.bids!)
                  ..sort((a, b) {
                    final ta = DateTime.tryParse(
                        (a.timestamp ?? '').replaceFirst(' ', 'T'));
                    final tb = DateTime.tryParse(
                        (b.timestamp ?? '').replaceFirst(' ', 'T'));
                    if (ta == null || tb == null) return 0;
                    return tb.compareTo(ta);
                  }))
                .first
                .amount
                ?.toInt()
            : null;
    final staticBase = widget.vehicle.basePrice?.toInt() ?? 0;
    final staticFloor =
        (staticTop != null && staticTop > 0) ? staticTop : staticBase;

    // Minimum valid next bid is the current highest/base price + increment
    _amount = staticFloor + _minIncrement;
    _amountController = TextEditingController(text: '$_amount');

    _computeRemaining();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _computeRemaining());

    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      Future.microtask(() {
        // 1. Snapshot fetch via HTTP
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId);

        // 2. Connect WebSocket and subscribe to real-time events
        final socket = ref.read(liveBidSocketProvider);
        socket.connect(
          onMessage: (data) {
            if (!mounted) return;
            // Silent refresh when an auction update message arrives
            ref
                .read(bidActivityNotifierProvider.notifier)
                .fetchBidActivity(vehicleId, silent: true);
          },
        );
        socket.subscribe(vehicleId);
      });
    }
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

  // ── Timer ────────────────────────────────────────────────────────
  void _computeRemaining() {
    final closeDt = widget.vehicle.auctionCloseDt;
    final parsed = (closeDt == null || closeDt.isEmpty)
        ? null
        : DateTime.tryParse(closeDt.replaceFirst(' ', 'T'));
    if (!mounted) return;
    if (parsed == null) {
      setState(() => _ended = true);
      return;
    }
    final diff = parsed.difference(DateTime.now());
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

  String _fmtTimer(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Live data ────────────────────────────────────────────────────
  BidActivityData? get _liveActivity =>
      ref.read(bidActivityNotifierProvider).maybeWhen(
            data: (data) => data,
            orElse: () => null,
          );

  List<BidsModel> _withKnownBidderNames(List<BidsModel> liveBids) {
    final staticBids = widget.vehicle.bids ?? const [];
    final nameById = <int, String>{
      for (final b in staticBids)
        if (b.id != null && (b.bidderName ?? '').trim().isNotEmpty)
          b.id!: b.bidderName!,
    };
    final nameByDealerId = <int, String>{
      for (final b in staticBids)
        if (b.dealerId != null && (b.bidderName ?? '').trim().isNotEmpty)
          b.dealerId!: b.bidderName!,
    };

    for (final bid in liveBids) {
      if ((bid.bidderName ?? '').trim().isNotEmpty) continue;
      final byId = bid.id != null ? nameById[bid.id] : null;
      final byDealer =
          bid.dealerId != null ? nameByDealerId[bid.dealerId] : null;
      bid.bidderName = byId ?? byDealer;
    }
    return liveBids;
  }

  List<BidsModel> get _sortedBids {
    final liveBids = _liveActivity?.bids;
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

  BidsModel? get _topBid => _sortedBids.isNotEmpty ? _sortedBids.first : null;

  double? _bestAmountForDealer(int? dealerId) {
    if (dealerId == null) return null;
    double? best;
    for (final b in _sortedBids) {
      if (b.dealerId != dealerId) continue;
      final amt = b.amount ?? 0;
      if (best == null || amt > best) best = amt;
    }
    return best;
  }

  /// Dense rank among every dealer's BEST bid only.
  int _liveRankForDealer(int? dealerId) {
    final myBest = _bestAmountForDealer(dealerId) ?? 0;
    final bestPerDealer = <int, double>{};
    for (final b in _sortedBids) {
      final id = b.dealerId;
      if (id == null) continue;
      final amt = b.amount ?? 0;
      if (!bestPerDealer.containsKey(id) || amt > bestPerDealer[id]!) {
        bestPerDealer[id] = amt;
      }
    }
    final higher = bestPerDealer.values.where((v) => v > myBest).length;
    return higher + 1;
  }

  int? get _currentDealerId =>
      widget.currentDealerId ?? ref.read(dLogic).user?.userId;

  bool get _hasMyBid => _bestAmountForDealer(_currentDealerId) != null;

  bool get _isCurrentUserWinning {
    final top = _topBid;
    final me = _currentDealerId;
    if (top == null || me == null) return false;
    return top.dealerId == me;
  }

  AutobidInfo? get _myAutobid => _liveActivity?.autobid;

  num? get _currentHighestBid => _liveActivity?.highestBid ?? _topBid?.amount;

  bool get _isAutobidExhausted =>
      _myAutobid?.isExhausted(_currentHighestBid) ?? false;

  bool get _isAutobidRunning =>
      _myAutobid != null && !_isAutobidExhausted && _myAutobid!.active == true;

  int _suggestedStartAmount() {
    final top = (_currentHighestBid ?? _topBid?.amount)?.toInt();
    final base = widget.vehicle.basePrice?.toInt() ?? 0;
    final floor = (top != null && top > 0) ? top : base;
    return floor + _minIncrement;
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

  // ── Result dialog ────────────────────────────────────────────────
  Future<void> _showResultDialog({
    required bool success,
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          color: success ? const Color(0xFF2E9E5B) : const Color(0xFFD64545),
          size: 40,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.of(context).pop(_amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    success ? const Color(0xFF2E9E5B) : const Color(0xFF3F51E8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('OK',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Place bid ────────────────────────────────────────────────────
  Future<void> _submitBid() async {
    if (_isAutobidRunning || _ended) return;

    if (_amount < _suggestedStartAmount()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Bid must be at least ${_formatAmount(_suggestedStartAmount())}'),
        ),
      );
      return;
    }

    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId == null || vehicleId.isEmpty) return;

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
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId, silent: true);
        _showResultDialog(
          success: true,
          title: 'Bid Placed!',
          message:
              'Your bid of ${_formatAmount(_amount)} was placed successfully.\nYour rank: #${data.rank ?? '-'}',
        );
      },
      error: (msg) => _showResultDialog(
        success: false,
        title: 'Bid Failed',
        message: msg,
      ),
    );
  }

  // ── Autobid ──────────────────────────────────────────────────────
  Future<void> _submitAutobid() async {
    if (_ended) return;

    if (_amount < _suggestedStartAmount()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Max bid must be at least ${_formatAmount(_suggestedStartAmount())}'),
        ),
      );
      return;
    }

    final existingCeiling = _myAutobid?.maxBidAmount;
    if (_isAutobidRunning &&
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

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Keep input field updated if a higher bid comes in while the user has the sheet open
    ref.listen(bidActivityNotifierProvider, (previous, next) {
      next.maybeWhen(
        data: (data) {
          final liveTop = data.highestBid?.toInt();
          if (liveTop != null) {
            final nextMin = liveTop + _minIncrement;
            if (_amount <= liveTop && mounted) {
              setState(() {
                _amount = nextMin;
                _amountController.text = '$_amount';
              });
            }
          }
        },
        orElse: () {},
      );
    });

    final v = widget.vehicle;
    final title = [v.mfgYear, v.make, v.model, v.variant]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' ');

    final placeBidState = ref.watch(placeBidNotifier);
    final autoBidState = ref.watch(autoBidNotifier);
    ref.watch(
        bidActivityNotifierProvider); // Rebuilds on activity state changes

    final isPlacingBid =
        placeBidState.maybeWhen(loading: () => true, orElse: () => false);
    final isEnablingAutobid =
        autoBidState.maybeWhen(loading: () => true, orElse: () => false);

    final showBanner = _isAutobidRunning || _isAutobidExhausted;

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
                      _header(title),
                      const SizedBox(height: 14),
                      _summaryTiles(),
                      const SizedBox(height: 12),
                      _statusHeader(),
                      if (showBanner) ...[
                        const SizedBox(height: 12),
                        _autobidStatusBanner(),
                      ],
                      const SizedBox(height: 22),
                      _detailsCard(),
                    ],
                  ),
                ),
                _actionPanel(isPlacingBid, isEnablingAutobid),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header: photo + title + reg no / specs + timer ──────────────
  Widget _header(String title) {
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
        _timerChip(),
      ],
    );
  }

  // ── Timer chip ──────────────────────────────────────────────────
  Widget _timerChip() {
    final Color bg;
    final Color fg;
    if (_ended) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD64545);
    } else if (_remaining.inMinutes < 60) {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB45309);
    } else {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF111111);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 15, color: fg),
          const SizedBox(width: 4),
          Text(
            _ended ? 'Ended' : _fmtTimer(_remaining),
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 12.5, color: fg),
          ),
        ],
      ),
    );
  }

  // ── Price summary ───────────────────────────────────────────────
  Widget _summaryTiles() {
    final current = _currentHighestBid;
    final currentLabel =
        (current != null && current > 0) ? _formatAmount(current) : 'No bids';
    final base = widget.vehicle.basePrice;

    return Row(
      children: [
        _summaryTile('Base price', base != null ? _formatAmount(base) : '—'),
        const SizedBox(width: 8),
        _summaryTile('Current bid', currentLabel),
        const SizedBox(width: 8),
        _summaryTile('Total bids', '${_sortedBids.length}'),
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

  // ── Status card: derived consistently from dealer rank ──────────
  Widget _statusHeader() {
    final hasBids = _topBid != null;
    final mine = _hasMyBid;
    final rank = mine ? _liveRankForDealer(_currentDealerId) : null;
    final winning = mine && (rank == 1 || _isCurrentUserWinning);

    final Color bg;
    final Color fg;
    final String label;
    final String sub;
    final IconData icon;

    if (!hasBids) {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
      label = 'No bids yet';
      sub = 'Be the first to bid on this vehicle';
      icon = Icons.hourglass_empty_rounded;
    } else if (winning) {
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      label = 'Winning';
      sub = 'You\'re the highest bidder';
      icon = Icons.emoji_events_rounded;
    } else if (mine) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD64545);
      label = 'Outbid';
      sub = 'Another dealer is ahead — raise your bid';
      icon = Icons.trending_down_rounded;
    } else {
      final n = _sortedBids.length;
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
          if (rank != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rank #$rank',
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

  // ── Autobid banner ──────────────────────────────────────────────
  Widget _autobidStatusBanner() {
    final max = _myAutobid?.maxBidAmount;
    final Color bg;
    final Color fg;
    final IconData icon;
    final String text;

    if (_isAutobidRunning) {
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      icon = Icons.bolt_rounded;
      text = max != null
          ? 'Your autobid is active up to ${_formatAmount(max)}. Raise it anytime; manual bidding is disabled until you\'re outbid.'
          : 'Your autobid is active. Raise it anytime; manual bidding is disabled until you\'re outbid.';
    } else {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB45309);
      icon = Icons.info_outline_rounded;
      text = max != null
          ? 'Your autobid reached its limit of ${_formatAmount(max)}. Place a new bid or set a higher autobid to continue.'
          : 'Your autobid has reached its limit. Place a new bid or set a higher autobid to continue.';
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

  // ── Pinned action panel: amount, helper, action button ───────────
  Widget _actionPanel(bool isPlacingBid, bool isEnablingAutobid) {
    final minAmount = _suggestedStartAmount();
    final tooLow = _amount < minAmount;

    final helper = tooLow
        ? 'Enter at least ${_formatAmount(minAmount)}'
        : _isAutobidMode
            ? 'Minimum max bid: ${_formatAmount(minAmount)}'
            : 'Minimum next bid: ${_formatAmount(minAmount)}';

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
                  'Autobid keeps bidding for you in ${_formatAmount(_minIncrement)} steps, up to your max.',
                  style:
                      const TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: _isAutobidMode
                  ? _autobidButton(isPlacingBid, isEnablingAutobid)
                  : _bidButton(isPlacingBid, isEnablingAutobid),
            ),
          ],
        ),
      ),
    );
  }

  // ── Buttons ──────────────────────────────────────────────────────
  Widget _bidButton(bool isPlacingBid, bool isEnablingAutobid) {
    return ElevatedButton.icon(
      onPressed:
          (_ended || isPlacingBid || isEnablingAutobid || _isAutobidRunning)
              ? null
              : _submitBid,
      icon: isPlacingBid
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Icon(Icons.gavel_rounded, size: 18),
      label: Text(
        _ended
            ? 'Auction ended'
            : isPlacingBid
                ? 'Placing...'
                : _isAutobidRunning
                    ? 'Auto bidding'
                    : 'Bid now',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F51E8),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF3F51E8).withOpacity(0.6),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _autobidButton(bool isPlacingBid, bool isEnablingAutobid) {
    return ElevatedButton.icon(
      onPressed:
          (_ended || isPlacingBid || isEnablingAutobid) ? null : _submitAutobid,
      icon: isEnablingAutobid
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Icon(
              _isAutobidRunning
                  ? Icons.trending_up_rounded
                  : Icons.bolt_rounded,
              size: 18),
      label: Text(
        _ended
            ? 'Auction ended'
            : isEnablingAutobid
                ? 'Enabling...'
                : _isAutobidRunning
                    ? 'Raise autobid'
                    : 'Set autobid',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E9E5B),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF2E9E5B).withOpacity(0.6),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Amount field ────────────────────────────────────────────────
  Widget _amountField() {
    return TextField(
      controller: _amountController,
      onChanged: _onAmountChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: _isAutobidMode ? 'Enter max amount' : 'Enter amount',
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

  // ── Vehicle + auction details ───────────────────────────────────
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
