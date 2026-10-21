// lib/features/live_auction/presentation/widgets/quote_price_sheet.dart

import 'dart:async';
import 'package:dealer/core/helper/feedback_helper.dart';
import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class QuotePriceSheet extends ConsumerStatefulWidget {
  final LiveAuctionModel vehicle;
  final int? currentDealerId;

  const QuotePriceSheet({
    super.key,
    required this.vehicle,
    this.currentDealerId,
  });

  @override
  ConsumerState<QuotePriceSheet> createState() => _QuotePriceSheetState();
}

class _QuotePriceSheetState extends ConsumerState<QuotePriceSheet> {
  late final TextEditingController _amountController;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  // Fixed visual boundaries: FROM (Start) & TO (Base)
  late final double _fromStartPrice;
  late final double _toBasePrice;
  late double _currentSliderValue;

  static const int _maxQuotesPerUser = 5;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    // 1. Resolve TO (Base Price Ceiling)
    final num rawBase = widget.vehicle.basePrice ?? 0;
    _toBasePrice = rawBase > 0 ? rawBase.toDouble() : 0.0;

    // 2. Resolve FROM (Start Price Floor)
    // If starting price is null, 0, or equal/greater than basePrice, fallback to 75% of base price
    final double? rawStart = widget.vehicle.startingprice;
    if (rawStart != null &&
        rawStart > 0 &&
        (_toBasePrice == 0 || rawStart < _toBasePrice)) {
      _fromStartPrice = rawStart;
    } else if (_toBasePrice > 0) {
      _fromStartPrice = (_toBasePrice * 0.75).roundToDouble();
    } else {
      _fromStartPrice = 0.0;
    }

    // 3. User's previous quote on this lot (from vehicle.bids passed in)
    final double userHighest =
        (widget.vehicle.bids != null && widget.vehicle.bids!.isNotEmpty)
            ? (widget.vehicle.bids!.first.amount ?? 0.0)
            : 0.0;

    final double initialTarget =
        userHighest > 0 ? (userHighest + 1000.0) : _fromStartPrice;

    if (_toBasePrice > _fromStartPrice) {
      _currentSliderValue = initialTarget.clamp(_fromStartPrice, _toBasePrice);
    } else {
      _currentSliderValue = _fromStartPrice;
    }

    _amountController = TextEditingController(
      text:
          _currentSliderValue > 0 ? _currentSliderValue.toInt().toString() : '',
    );

    _computeRemaining();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _computeRemaining());

    // 4. WebSocket & Fresh Bid Activity Fetch
    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      Future.microtask(() {
        // Fetch fresh bid activity for this exact vehicle
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId);

        final socket = ref.read(liveBidSocketProvider);
        socket.connect(
          onMessage: (data) {
            if (!mounted) return;
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

  int? get _currentDealerId =>
      widget.currentDealerId ?? ref.read(dLogic).user?.userId;

  /// STRICT CHECK: Ignore cached data if the vehicleId does not match current vehicle!
  BidActivityData? get _liveActivity {
    final stateData = ref.read(bidActivityNotifierProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );

    final currentId = widget.vehicle.vehicleId;
    if (currentId == null || currentId.isEmpty) return null;

    // Check if the cached provider data actually belongs to THIS vehicle
    final cachedVehicleId = stateData?.auction?.vehicleId ??
        (stateData?.bids?.isNotEmpty == true
            ? stateData!.bids!.first.vehicleId
            : null);

    if (cachedVehicleId != null && cachedVehicleId != currentId) {
      return null; // Stale data from previous vehicle discarded!
    }

    return stateData;
  }

  List<BidsModel> get _sortedBids {
    final liveBids = _liveActivity?.bids;
    // Use live bids only if they match this vehicle, otherwise use widget.vehicle.bids
    final bids =
        List<BidsModel>.from(liveBids ?? widget.vehicle.bids ?? const []);
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

  int get _myQuoteCount {
    final me = _currentDealerId;
    if (me == null) return 0;
    return _sortedBids.where((b) => b.dealerId == me).length;
  }

  bool get _isQuoteLimitReached => _myQuoteCount >= _maxQuotesPerUser;

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

  bool get _hasMyBid => _bestAmountForDealer(_currentDealerId) != null;

  num? get _myHighestBid => _bestAmountForDealer(_currentDealerId);

  bool get _isCurrentUserWinning {
    final top = _topBid;
    final me = _currentDealerId;
    if (top == null || me == null) return false;
    return top.dealerId == me;
  }

  double get _effectiveMinPrice {
    final double liveTop =
        (_liveActivity?.highestBid ?? _topBid?.amount ?? 0.0).toDouble();
    if (liveTop > 0) {
      return liveTop + 1000.0;
    }
    return _fromStartPrice;
  }

  void _computeRemaining() {
    final closeDt =
        widget.vehicle.extendedEndTime ?? widget.vehicle.auctionCloseDt;
    final target = AuctionDateHelper.parseAuctionDate(closeDt);
    if (target == null) {
      if (mounted) setState(() => _ended = true);
      return;
    }
    final diff = target.difference(DateTime.now());
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

  String _fmtTimer(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDisplayPrice(num? amount) {
    if (amount == null || amount <= 0) return '₹0';
    return _currencyFormatter.format(amount);
  }

  void _onAmountTextChanged(String val) {
    final clean = val.replaceAll(',', '').trim();
    final parsed = double.tryParse(clean) ?? 0.0;

    setState(() {
      if (_toBasePrice > _fromStartPrice) {
        _currentSliderValue = parsed.clamp(_fromStartPrice, _toBasePrice);
      }
    });
  }

  void _onSliderChanged(double value) {
    final rounded = (value / 1000).round() * 1000;
    setState(() {
      _currentSliderValue = rounded.toDouble();
      final textValue = rounded.toString();
      _amountController.value = TextEditingValue(
        text: textValue,
        selection: TextSelection.collapsed(offset: textValue.length),
      );
    });
  }

  Future<void> _submitQuote() async {
    if (_isQuoteLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
              'Quote auction allows up to 5 bids per user for this vehicle.'),
        ),
      );
      return;
    }

    final clean = _amountController.text.replaceAll(',', '').trim();
    final int? amount = int.tryParse(clean);
    if (amount == null) return;

    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId == null || vehicleId.isEmpty) return;

    await ref.read(placeBidNotifier.notifier).placeBid(
          vehicleId: vehicleId,
          bidAmount: amount.toDouble(),
        );

    if (!mounted) return;

    final result = ref.read(placeBidNotifier);
    result.whenOrNull(
      data: (data) async {
        await FeedbackHelper.success();
        ref.read(auctionLogic).search();
        ref
            .read(bidActivityNotifierProvider.notifier)
            .fetchBidActivity(vehicleId, silent: true);
        Navigator.pop(context, amount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text(
                'Quote of ${_formatDisplayPrice(amount)} submitted successfully!'),
          ),
        );
      },
      error: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              msg.isNotEmpty
                  ? msg
                  : 'Failed to submit quote. Please check quote limit or enter higher amount.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bidActivityNotifierProvider, (previous, next) {
      next.maybeWhen(
        data: (data) {
          // Reject updates belonging to a different vehicle
          final currentId = widget.vehicle.vehicleId;
          final updatedVehicleId = data.auction?.vehicleId ??
              (data.bids?.isNotEmpty == true
                  ? data.bids!.first.vehicleId
                  : null);

          if (updatedVehicleId != null &&
              currentId != null &&
              updatedVehicleId != currentId) {
            return;
          }

          _computeRemaining();

          final liveTop = data.highestBid?.toDouble();
          if (liveTop != null && liveTop > 0 && mounted) {
            final nextValidTarget = liveTop + 1000.0;
            final currentVal =
                double.tryParse(_amountController.text.replaceAll(',', '')) ??
                    0.0;

            if (currentVal < nextValidTarget) {
              setState(() {
                if (_toBasePrice > _fromStartPrice) {
                  _currentSliderValue =
                      nextValidTarget.clamp(_fromStartPrice, _toBasePrice);
                }
                final newText = nextValidTarget.toInt().toString();
                _amountController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: newText.length),
                );
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
    final specs = [
      v.fuel,
      v.kmsDriven != null ? '${v.kmsDriven}K km' : null,
      v.ownerCount != null ? '${v.ownerCount}nd owner' : null,
    ].where((e) => e != null).join(' · ');

    final cleanText = _amountController.text.replaceAll(',', '').trim();
    final num enteredAmount = num.tryParse(cleanText) ?? 0;

    final double minRequired = _effectiveMinPrice;
    final bool isTooLow = enteredAmount > 0 && enteredAmount < minRequired;
    final bool isTooHigh = enteredAmount > _toBasePrice && _toBasePrice > 0;
    final bool isValid = enteredAmount >= minRequired &&
        (_toBasePrice == 0 || enteredAmount <= _toBasePrice) &&
        !_ended &&
        !_isQuoteLimitReached;

    final isSubmitting = ref.watch(placeBidNotifier).maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

    final bool canSlide =
        _toBasePrice > _fromStartPrice && !_isQuoteLimitReached;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 10, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Quote your best price',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 22, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Mini Vehicle Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: const Color(0xFFF1F5F9),
                        child: (v.imageUrl?.url?.isNotEmpty == true)
                            ? Image.network(
                                v.imageUrl!.url!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.directions_car,
                                    color: Colors.grey),
                              )
                            : const Icon(Icons.directions_car,
                                color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : 'Vehicle',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            specs,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Auction ID: ${v.vehicleId ?? "-"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Tiles: Base Price, Your Quote, Quotes Placed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _summaryTiles(),
              ),

              const SizedBox(height: 10),

              // Quote limit alert if max attempts reached
              if (_isQuoteLimitReached)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFFDC2626), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quote auction allows up to 5 bids per user for this vehicle.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 6),

              // Status Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _statusHeader(),
              ),

              const SizedBox(height: 12),

              // Amount Input Field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Column(
                  children: [
                    const Text(
                      'Enter Amount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      enabled: !_isQuoteLimitReached && !_ended,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _onAmountTextChanged,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _isQuoteLimitReached
                            ? const Color(0xFF94A3B8)
                            : (isTooLow || isTooHigh
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0F172A)),
                      ),
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _isQuoteLimitReached
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isTooLow && !_isQuoteLimitReached)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text(
                            "Next quote must be at least ${_formatDisplayPrice(minRequired)}",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else if (isTooHigh && !_isQuoteLimitReached)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text(
                            "Quote can't exceed base price (${_formatDisplayPrice(_toBasePrice)})",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 18),
                  ],
                ),
              ),

              // Interactive Slider
              if (canSlide)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 5,
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: AppColors.primary,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 9),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 18),
                        ),
                        child: Slider(
                          value: _currentSliderValue.clamp(
                              _fromStartPrice, _toBasePrice),
                          min: _fromStartPrice,
                          max: _toBasePrice,
                          onChanged: _onSliderChanged,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDisplayPrice(_fromStartPrice),
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800),
                                ),
                                const Text(
                                  'Start price (From)',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatDisplayPrice(_toBasePrice),
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800),
                                ),
                                const Text(
                                  'Base price (To)',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // Timer & Target Base Price Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: _ended ? Colors.red : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _ended ? 'Ended' : _fmtTimer(_remaining),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color:
                                _ended ? Colors.red : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Base price ${_formatDisplayPrice(_toBasePrice)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (isValid && !isSubmitting) ? _submitQuote : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isQuoteLimitReached
                                ? 'Quote Limit Reached (5/5)'
                                : (_isCurrentUserWinning
                                    ? 'Raise Higher Quote'
                                    : 'Confirm Quote'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Tiles: Base price / user's highest quote / quotes used ──
  Widget _summaryTiles() {
    final myBid = _myHighestBid;
    final myBidLabel =
        (myBid != null && myBid > 0) ? _formatDisplayPrice(myBid) : 'No quotes';
    final base = widget.vehicle.basePrice;

    return Row(
      children: [
        _summaryTile(
            'Base price', base != null ? _formatDisplayPrice(base) : '—'),
        const SizedBox(width: 8),
        _summaryTile('Your quote', myBidLabel),
        const SizedBox(width: 8),
        _summaryTile('Quotes placed', '$_myQuoteCount/$_maxQuotesPerUser'),
      ],
    );
  }

  Widget _summaryTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Banner: Winning, Outbid, Quotes Active, Limit Reached ────
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

    if (_isQuoteLimitReached) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
      label = 'Maximum limit reached';
      sub = '5 quotes have been submitted for this lot';
      icon = Icons.block_rounded;
    } else if (!hasBids) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      label = 'No quotes yet';
      sub = 'Submit the first quote for this vehicle';
      icon = Icons.hourglass_empty_rounded;
    } else if (winning) {
      bg = const Color(0xFFDFF3E4);
      fg = const Color(0xFF2E9E5B);
      label = 'Winning';
      sub =
          "You're highest bidder (${_maxQuotesPerUser - _myQuoteCount} quotes left). Raise if desired.";
      icon = Icons.emoji_events_rounded;
    } else if (mine) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFFD64545);
      label = 'Outbid';
      sub =
          'Another dealer quoted higher — raise your price (${_maxQuotesPerUser - _myQuoteCount} left)';
      icon = Icons.trending_down_rounded;
    } else {
      final n = _sortedBids.length;
      bg = const Color(0xFFEEF2FF);
      fg = AppColors.primary;
      label = 'Quotes active';
      sub = '$n quote${n == 1 ? '' : 's'} placed — submit yours';
      icon = Icons.gavel_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: fg.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (rank != null && !_isQuoteLimitReached)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Rank #$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
