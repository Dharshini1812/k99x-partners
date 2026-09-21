// lib/features/live_auction/presentation/widgets/place_bid_sheet.dart

import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';

import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaceBidSheet extends ConsumerStatefulWidget {
  final LiveAuctionModel vehicle;
  final int? currentDealerId;
  const PlaceBidSheet({
    super.key,
    required this.vehicle,
    this.currentDealerId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends ConsumerState<PlaceBidSheet> {
  late final TextEditingController _amountController;
  late int _amount;

  static const int _minIncrement = 1000;
  static const List<int> _quickAdds = [1000, 5000];

  @override
  void initState() {
    super.initState();
    // NOTE: can't use _suggestedStartAmount() here — it reads
    // _liveActivity, which calls ref.watch(), and ref.watch() isn't
    // allowed in initState(). Seed from the static snapshot only;
    // build() recomputes (and the field updates) once live data is in.
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
    _amount = staticFloor + _minIncrement;
    _amountController = TextEditingController(text: '$_amount');

    // Start polling live bid activity (bids, highestBid, autobid state)
    // for this vehicle while the sheet is open — without this, the
    // sheet only ever shows the static bids snapshot the vehicle card
    // was built with, and never learns that its own (or anyone else's)
    // autobid has fired or been exhausted while the sheet is up.
    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      Future.microtask(() {
        ref.read(bidActivityNotifierProvider.notifier).startPolling(vehicleId);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    ref.read(bidActivityNotifierProvider.notifier).stopPolling();
    super.dispose();
  }

  /// Live activity data once the first poll resolves; null until then
  /// (falls back to the static `widget.vehicle` snapshot below).
  ///
  /// Deliberately uses ref.read, not ref.watch — this getter (and
  /// everything built on it: _sortedBids, _myAutobid, _suggestedStartAmount,
  /// etc.) is also called from button onPressed handlers, and ref.watch
  /// is only valid during build(). build() below does its own explicit
  /// ref.watch(bidActivityNotifierProvider) to register for rebuilds
  /// whenever new activity data arrives; this getter just reads the
  /// resulting value.
  BidActivityData? get _liveActivity =>
      ref.read(bidActivityNotifierProvider).maybeWhen(
            data: (data) => data,
            orElse: () => null,
          );

  /// The `bid/activity/{vehicleId}` endpoint (used for live polling)
  /// doesn't send `bidderName` at all — only the initial snapshot from
  /// the auctions list (`widget.vehicle.bids`) does. Left alone, every
  /// bid shown once polling data arrives falls back to "Anonymous
  /// bidder", even for names we already know. This fills a live bid's
  /// name in from the static snapshot, matched by bid id first (most
  /// reliable), falling back to dealerId if the same bid id isn't in
  /// the static list yet (e.g. it arrived after the sheet opened).
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

  /// Dense rank (1 = highest amount) for a bid within the current
  /// activity list — used so the feed can show standing without
  /// revealing anyone's actual bid amount. Ties share a rank.
  int _rankFor(BidsModel bid) {
    final amount = bid.amount ?? 0;
    final higher = _sortedBids.where((b) => (b.amount ?? 0) > amount).length;
    return higher + 1;
  }

  /// This dealer's own best (highest) bid amount in the current list —
  /// the one that actually represents where they stand right now. A
  /// dealer who has bid more than once has older bids sitting below
  /// this that no longer mean anything competitively; they were
  /// superseded the moment the dealer placed their next, higher bid.
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

  /// True if [bid] is the dealer's current best bid — i.e. the one
  /// that should actually carry a live rank. False for any earlier,
  /// lower bid from that same dealer, since a later bid from them
  /// already supersedes it.
  bool _isDealersCurrentBid(BidsModel bid) {
    final best = _bestAmountForDealer(bid.dealerId);
    return best != null && (bid.amount ?? 0) == best;
  }

  /// The real, live standing rank for a dealer — dense rank among
  /// every dealer's BEST bid only (not every individual bid event).
  /// This is what "Rank #1" should actually mean: 1st place overall,
  /// not "1st among however many times this one dealer has bid."
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

  bool get _isCurrentUserWinning {
    final top = _topBid;
    final me = _currentDealerId;
    if (top == null || me == null) return false;
    return top.dealerId == me;
  }

  /// This dealer's own autobid record for this vehicle, from live
  /// activity — null if they've never set one (or it hasn't loaded
  /// yet, in which case the Autobid button behaves as if there's none
  /// set, same as before this wiring existed).
  AutobidInfo? get _myAutobid => _liveActivity?.autobid;

  num? get _currentHighestBid => _liveActivity?.highestBid ?? _topBid?.amount;

  /// True once this dealer's autobid ceiling has been used up — the
  /// backend has either deactivated it or the running price has caught
  /// up to (or passed) the max they approved. While this is true, the
  /// "Autobid" button is disabled: raising the price further needs a
  /// fresh manual bid, same as if no autobid was ever set.
  bool get _isAutobidExhausted =>
      _myAutobid?.isExhausted(_currentHighestBid) ?? false;

  /// True while this dealer's autobid is still live and able to raise
  /// itself on their behalf — the "Autobid" button is disabled here
  /// too, since there's nothing more for the dealer to do until either
  /// they're outbid past their ceiling (→ exhausted) or they win.
  bool get _isAutobidRunning =>
      _myAutobid != null && !_isAutobidExhausted && _myAutobid!.active == true;

  int _suggestedStartAmount() {
    final top = (_currentHighestBid ?? _topBid?.amount)?.toInt();
    final base = widget.vehicle.basePrice?.toInt() ?? 0;
    final floor = (top != null && top > 0) ? top : base;
    return floor + _minIncrement;
  }

  void _applyQuickAdd(int delta) {
    setState(() {
      _amount += delta;
      _amountController.text = '$_amount';
      _amountController.selection = TextSelection.collapsed(
        offset: _amountController.text.length,
      );
    });
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

  String _relativeTime(String? raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed == null) return '';
    final diff = DateTime.now().difference(parsed);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
                Navigator.of(context).pop(); // close dialog
                if (success) {
                  Navigator.of(context)
                      .pop(_amount); // close sheet, return amount
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
    if (_isAutobidRunning) {
      return;
    }

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
        final vehicleId = widget.vehicle.vehicleId;
        if (vehicleId != null && vehicleId.isNotEmpty) {
          ref
              .read(bidActivityNotifierProvider.notifier)
              .fetchBidActivity(vehicleId, silent: true);
        }
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
    // Unlike _submitBid, this is intentionally NOT gated on
    // _isAutobidRunning: a dealer with an active autobid must still be
    // able to raise their own ceiling (e.g. 500,000 → 600,000) without
    // waiting to be outbid first. The backend treats a fresh
    // enableAutoBid call as "update my ceiling", not "place a manual
    // bid on top of my own autobid" — the latter is what's actually
    // rejected, and that's still the manual Bid button's job to avoid.

    if (_amount < _suggestedStartAmount()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Max bid must be at least ${_formatAmount(_suggestedStartAmount())}'),
        ),
      );
      return;
    }

    // Raising an existing ceiling only means something if the new
    // number is actually higher than the one already on file.
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
        // Refresh activity immediately so _myAutobid reflects the new
        // autobid right away, instead of waiting for the next 3s poll.
        final vehicleId = widget.vehicle.vehicleId;
        if (vehicleId != null && vehicleId.isNotEmpty) {
          ref
              .read(bidActivityNotifierProvider.notifier)
              .fetchBidActivity(vehicleId, silent: true);
        }
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
    final v = widget.vehicle;
    final title = [v.mfgYear, v.make, v.model, v.variant]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' ');

    final placeBidState = ref.watch(placeBidNotifier);
    final autoBidState = ref.watch(autoBidNotifier);
    // Registers this widget to rebuild whenever a new poll of bid
    // activity lands — _liveActivity (used by _sortedBids, _myAutobid,
    // _suggestedStartAmount, etc.) reads the value with ref.read so it
    // stays safe to call from button handlers too; this is the one
    // place that actually subscribes to it.
    ref.watch(bidActivityNotifierProvider);

    final isPlacingBid = placeBidState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final isEnablingAutobid = autoBidState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Place Your Bid',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                        _statusPill(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isCurrentUserWinning || _myAutobid != null) ...[
                      _autobidStatusBanner(),
                      const SizedBox(height: 12),
                    ],
                    _amountField(),
                    const SizedBox(height: 6),
                    Text(
                      'Minimum next bid: ${_formatAmount(_suggestedStartAmount())}',
                      style: const TextStyle(
                          fontSize: 11.5, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: _quickAdds
                          .map((q) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: q == _quickAdds.first ? 10 : 0),
                                  child: _quickAddButton(q),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              // Disabled ONLY while this dealer's own
                              // autobid is actively holding the lead —
                              // manually bidding on top of your own
                              // live autobid is what the backend
                              // rejects with a 400. Being on top via a
                              // plain manual bid, or via an autobid
                              // that's already exhausted its ceiling,
                              // is fine to bid on again.
                              onPressed: (isPlacingBid ||
                                      isEnablingAutobid ||
                                      _isAutobidRunning)
                                  ? null
                                  : _submitBid,
                              icon: isPlacingBid
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.gavel_rounded, size: 18),
                              label: Text(
                                isPlacingBid
                                    ? 'Placing...'
                                    : _isAutobidRunning
                                        ? 'Auto bidding'
                                        : 'Bid now',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F51E8),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFF3F51E8).withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              // Autobid stays enabled even while this
                              // dealer's own autobid is running — that's
                              // how they raise their ceiling (e.g.
                              // 500,000 → 600,000) without waiting to
                              // be outbid first. Only an in-flight
                              // request (placing a bid or already
                              // submitting a new ceiling) blocks it.
                              onPressed: (isPlacingBid || isEnablingAutobid)
                                  ? null
                                  : _submitAutobid,
                              icon: isEnablingAutobid
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      _isAutobidRunning
                                          ? Icons.trending_up_rounded
                                          : Icons.bolt_rounded,
                                      size: 18),
                              label: Text(
                                isEnablingAutobid
                                    ? 'Enabling...'
                                    : _isAutobidRunning
                                        ? 'Raise autobid'
                                        : 'Autobid',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E9E5B),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFF2E9E5B).withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _liveActivityHeader(),
                    const SizedBox(height: 10),
                    if (_sortedBids.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No bids yet — be the first to bid!',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      )
                    else
                      ..._sortedBids.map((b) => _bidActivityRow(b)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Banner shown above the amount field whenever this dealer has (or
  /// had) an autobid running on this vehicle, or is winning outright.
  ///
  /// Strictly amount-free — no current bid, no ceiling, for anyone,
  /// including the dealer's own numbers. Status/rank language only
  /// ("You're winning", "your autobid is active", "raise it anytime").
  Widget _autobidStatusBanner() {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String text;

    if (_isAutobidRunning) {
      // Manual Bid is blocked while your own autobid holds the lead —
      // but Autobid itself stays live so you can raise the ceiling.
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      icon = Icons.emoji_events_rounded;
      text =
          'You\'re currently winning — your autobid is active. Raise it anytime; manual bidding is disabled until you\'re outbid.';
    } else if (_isAutobidExhausted) {
      // Ceiling reached — nothing is disabled from here: they can bid
      // manually, or set a fresh (higher) autobid if they want to.
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB45309);
      icon = Icons.info_outline_rounded;
      text =
          'Your autobid has reached its limit. Place a new bid or set a higher autobid to continue.';
    } else if (_isCurrentUserWinning) {
      // Winning via a plain manual bid — purely informational, nothing
      // is disabled.
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      icon = Icons.emoji_events_rounded;
      text = 'You\'re currently the highest bidder on this vehicle.';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
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

  Widget _statusPill() {
    final hasBids = _topBid != null;
    final winning = _isCurrentUserWinning;
    final Color bg;
    final Color fg;
    final String label;
    if (!hasBids) {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
      label = 'No bids yet';
    } else if (winning) {
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      label = 'Winning';
    } else {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD64545);
      label = 'Outbid';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _amountField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Text('₹',
              style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF))),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _amountController,
              onChanged: _onAmountChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAddButton(int amount) {
    return OutlinedButton(
      onPressed: () => _applyQuickAdd(amount),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('+${_formatAmount(amount)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
    );
  }

  Widget _liveActivityHeader() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFD64545),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Live Bidding Activity',
          style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111)),
        ),
        const Spacer(),
        Text(
          '${_sortedBids.length} bid${_sortedBids.length == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _bidActivityRow(BidsModel b) {
    final myDealerId = _currentDealerId;

    final isTop = b == _topBid;
    final isMine = myDealerId != null && myDealerId == b.dealerId;
    final name = (b.bidderName == null || b.bidderName!.trim().isEmpty)
        ? 'Anonymous bidder'
        : b.bidderName!;
    final isCurrentForDealer = _isDealersCurrentBid(b);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTop ? const Color(0xFFF6F8FF) : Colors.white,
        border: Border.all(
          color: isTop ? const Color(0xFFDDE3FB) : const Color(0xFFF0F1F3),
          width: isTop ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMine
                  ? const LinearGradient(
                      colors: [Color(0xFF4F5FF0), Color(0xFF3F51E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMine ? null : const Color(0xFFE5E7EB),
            ),
            alignment: Alignment.center,
            child: Text(
              name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isMine ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMine ? 'You' : name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (b.isAutoBid == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Auto',
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F51E8))),
                      ),
                    ],
                  ],
                ),
                Text(
                  _relativeTime(b.timestamp),
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          isCurrentForDealer
              ? _rankBadge(_liveRankForDealer(b.dealerId))
              : _earlierBidTag(),
        ],
      ),
    );
  }

  /// Shown instead of a rank badge for a bid that's already been
  /// superseded by that same dealer's own later, higher bid — it's
  /// history, not part of the live standings anymore.
  Widget _earlierBidTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Earlier bid',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  /// Standing badge shown in place of a bid amount for EVERY row —
  /// including the current dealer's own bids. No one's actual bid
  /// amount is ever shown in this feed, rank only, no exceptions.
  ///
  /// Top 3 get a warm gradient pill with a medal icon and a matching
  /// glow-tinted shadow so the leaderboard reads at a glance; rank 1
  /// is pushed a touch further (extra padding, bolder weight, a small
  /// "Leading" caption) so first place is unmistakable even in a fast
  /// scroll. Ranks beyond 3 stay a simple neutral chip on purpose, so
  /// attention stays on the top of the leaderboard.
  Widget _rankBadge(int rank) {
    List<Color>? gradient;
    Color fg;
    Color? glow;
    IconData? icon;
    String? caption;

    switch (rank) {
      case 1:
        gradient = const [Color(0xFFFFE8A3), Color(0xFFFFB800)];
        fg = const Color(0xFF6B3F00);
        glow = const Color(0xFFFFB800);
        icon = Icons.emoji_events_rounded;
        caption = 'Leading';
        break;
      case 2:
        gradient = const [Color(0xFFEDEFF6), Color(0xFFC9CEDD)];
        fg = const Color(0xFF454B5C);
        glow = const Color(0xFFC9CEDD);
        icon = Icons.emoji_events_rounded;
        break;
      case 3:
        gradient = const [Color(0xFFF6DFC7), Color(0xFFE0A97C)];
        fg = const Color(0xFF6B3A15);
        glow = const Color(0xFFE0A97C);
        icon = Icons.emoji_events_rounded;
        break;
      default:
        gradient = null;
        fg = const Color(0xFF6B7280);
        glow = null;
        icon = null;
    }

    final isTopThree = rank <= 3;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: rank == 1 ? 15 : 14, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              '#$rank',
              style: TextStyle(
                fontSize: rank == 1 ? 12.5 : 12,
                fontWeight: isTopThree ? FontWeight.w800 : FontWeight.w700,
                color: fg,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rank == 1 ? 13 : 11,
        vertical: rank == 1 ? 7 : 6,
      ),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradient == null ? const Color(0xFFF3F4F6) : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: glow != null
            ? [
                BoxShadow(
                  color: glow.withOpacity(0.4),
                  blurRadius: rank == 1 ? 10 : 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: content,
    );
  }
}
