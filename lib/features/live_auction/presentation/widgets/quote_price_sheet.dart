// lib/features/live_auction/presentation/widgets/quote_price_sheet.dart

import 'dart:async';
import 'package:dealer/core/helper/feedback_helper.dart';
import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class QuotePriceSheet extends ConsumerStatefulWidget {
  final LiveAuctionModel vehicle;

  const QuotePriceSheet({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<QuotePriceSheet> createState() => _QuotePriceSheetState();
}

class _QuotePriceSheetState extends ConsumerState<QuotePriceSheet> {
  late final TextEditingController _amountController;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  late final double _fromStartPrice;
  late final double _toBasePrice;
  late double _currentSliderValue;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    // 1. Resolve TO (Base Price / OCB Price)
    final num rawBase = widget.vehicle.basePrice ?? 0;
    _toBasePrice = rawBase > 0 ? rawBase.toDouble() : 0.0;

    // 2. Resolve FROM (Start Price)
    final num? rawStart =
        (widget.vehicle.bids != null && widget.vehicle.bids!.isNotEmpty)
            ? widget.vehicle.bids!.first.amount
            : null;

    if (rawStart != null && rawStart > 0) {
      _fromStartPrice = rawStart.toDouble();
    } else if (_toBasePrice > 0) {
      _fromStartPrice = (_toBasePrice * 0.75).roundToDouble();
    } else {
      _fromStartPrice = 0.0;
    }

    _currentSliderValue = _fromStartPrice;
    _amountController = TextEditingController(
      text: _fromStartPrice > 0 ? _fromStartPrice.toInt().toString() : '',
    );

    _computeRemaining();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _computeRemaining());

    // 3. Connect WebSocket and subscribe to real-time events identically to PlaceBidSheet
    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId != null && vehicleId.isNotEmpty) {
      Future.microtask(() {
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
    final clean = _amountController.text.replaceAll(',', '').trim();
    final int? amount = int.tryParse(clean);
    if (amount == null) return;

    final vehicleId = widget.vehicle.vehicleId;
    if (vehicleId == null || vehicleId.isEmpty) return;

    // Send the sanitized integer without decimal places and without passing mode
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
            content: Text(msg.isNotEmpty ? msg : 'Failed to submit quote'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for live socket / poller activity updates identically to bidding
    ref.listen(bidActivityNotifierProvider, (previous, next) {
      next.maybeWhen(
        data: (data) {
          _computeRemaining();
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
      // v.transmissionType ?? 'Manual',
      v.kmsDriven != null ? '${v.kmsDriven}K km' : null,
      v.ownerCount != null ? '${v.ownerCount}nd owner' : null,
    ].where((e) => e != null).join(' · ');

    final cleanText = _amountController.text.replaceAll(',', '').trim();
    final num enteredAmount = num.tryParse(cleanText) ?? 0;

    final bool isTooLow = enteredAmount > 0 && enteredAmount < _fromStartPrice;
    final bool isTooHigh = enteredAmount > _toBasePrice && _toBasePrice > 0;
    final bool isValid = enteredAmount >= _fromStartPrice &&
        (_toBasePrice == 0 || enteredAmount <= _toBasePrice) &&
        !_ended;

    final isSubmitting = ref.watch(placeBidNotifier).maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

    final bool canSlide = _toBasePrice > _fromStartPrice;

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

              // Amount Input Field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _onAmountTextChanged,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isTooLow || isTooHigh
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isTooLow)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text(
                            "Entered amount can't be lower than start price (${_formatDisplayPrice(_fromStartPrice)})",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else if (isTooHigh)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text(
                            "Entered amount can't be higher than base price (${_formatDisplayPrice(_toBasePrice)})",
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

              // Interactive Slider from Start Price to Base Price
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
                      backgroundColor: const Color(0xFF4335DE),
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
                        : const Text(
                            'Confirm Quote',
                            style: TextStyle(
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
}
