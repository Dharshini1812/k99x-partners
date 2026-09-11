// lib/features/live_auction/presentation/widgets/place_bid_sheet.dart

import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';

import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
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
    _amount = _suggestedStartAmount();
    _amountController = TextEditingController(text: '$_amount');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<BidsModel> get _sortedBids {
    final bids = List<BidsModel>.from(widget.vehicle.bids ?? const []);
    bids.sort((a, b) {
      final ta = DateTime.tryParse((a.timestamp ?? '').replaceFirst(' ', 'T'));
      final tb = DateTime.tryParse((b.timestamp ?? '').replaceFirst(' ', 'T'));
      if (ta == null || tb == null) return 0;
      return tb.compareTo(ta);
    });
    return bids;
  }

  BidsModel? get _topBid => _sortedBids.isNotEmpty ? _sortedBids.first : null;

  bool get _isCurrentUserWinning {
    final top = _topBid;
    if (top == null || widget.currentDealerId == null) return false;
    return top.dealerId == widget.currentDealerId;
  }

  int _suggestedStartAmount() {
    final top = _topBid?.amount?.toInt();
    final base = widget.vehicle.basePrice?.toInt() ?? 0;
    final floor = top ?? base;
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
      data: (data) => _showResultDialog(
        success: true,
        title: 'Bid Placed!',
        message:
            'Your bid of ${_formatAmount(_amount)} was placed successfully.\nYour rank: #${data.rank ?? '-'}',
      ),
      error: (msg) => _showResultDialog(
        success: false,
        title: 'Bid Failed',
        message: msg,
      ),
    );
  }

  // ── Autobid ──────────────────────────────────────────────────────
  Future<void> _submitAutobid() async {
    if (_amount < _suggestedStartAmount()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Max bid must be at least ${_formatAmount(_suggestedStartAmount())}'),
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
      data: (data) => _showResultDialog(
        success: true,
        title: 'Autobid Enabled!',
        message: '${data.message}\nMax amount: ${_formatAmount(_amount)}',
      ),
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
                              onPressed: (isPlacingBid || isEnablingAutobid)
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
                                isPlacingBid ? 'Placing...' : 'Bid now',
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
                                  : const Icon(Icons.bolt_rounded, size: 18),
                              label: Text(
                                isEnablingAutobid ? 'Enabling...' : 'Autobid',
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
    final user = ref.read(dLogic).user;

    final isTop = b == _topBid;
    final name = (b.bidderName == null || b.bidderName!.trim().isEmpty)
        ? 'Anonymous bidder'
        : b.bidderName!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTop ? const Color(0xFFF6F8FF) : Colors.white,
        border: Border.all(
          color: isTop ? const Color(0xFFDDE3FB) : const Color(0xFFF0F1F3),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                isTop ? const Color(0xFF3F51E8) : const Color(0xFFE5E7EB),
            child: Text(
              name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isTop ? Colors.white : const Color(0xFF6B7280),
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
                        user?.userId == b.dealerId ? 'You' : name,
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
          Text(
            _formatAmount(b.amount ?? 0),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isTop ? const Color(0xFF3F51E8) : const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
