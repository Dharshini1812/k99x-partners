import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/pages/vehicle_detail_page.dart';
import 'package:dealer/features/live_auction/presentation/widgets/place_bid_sheet.dart';

class LiveAuctionCard extends StatefulWidget {
  final LiveAuctionModel vehicle;
  const LiveAuctionCard({super.key, required this.vehicle});

  @override
  State<LiveAuctionCard> createState() => _LiveAuctionCardState();
}

class _LiveAuctionCardState extends State<LiveAuctionCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _computeRemaining();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _computeRemaining());
  }

  @override
  void didUpdateWidget(covariant LiveAuctionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicle.auctionCloseDt != widget.vehicle.auctionCloseDt) {
      _computeRemaining();
    }
  }

  void _computeRemaining() {
    final closeDt = widget.vehicle.auctionCloseDt;
    if (closeDt == null || closeDt.isEmpty) {
      if (mounted) setState(() => _ended = true);
      return;
    }
    final parsed = DateTime.tryParse(closeDt.replaceFirst(' ', 'T'));
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

  /// Safely gets the highest / current bid amount, or null if there
  /// are no bids yet. `bids?.first` throws "Bad state: No element"
  /// when `bids` is a non-null but *empty* list, so guard on length too.
  double? _currentBidAmount(LiveAuctionModel v) {
    final bids = v.bids;
    if (bids == null || bids.isEmpty) return null;
    return bids.first.amount;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openBidSheet() {
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceBidSheet(vehicle: widget.vehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final title = [v.mfgYear, v.make, v.model, v.variant]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' ');
    final location = [v.cityName, v.stateName]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join('  ');
    final specs = [
      v.fuel,
      v.kmsDriven != null ? '${v.kmsDriven}K km' : null,
      v.ownerCount != null
          ? '${v.ownerCount} owner${v.ownerCount == 1 ? '' : 's'}'
          : null,
    ].where((e) => e != null).join(' • ');
    final currentBid = _currentBidAmount(v);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VehicleDetailPage(
                    vehicleId: widget.vehicle.vehicleId ?? '',
                    vehicle: widget.vehicle,
                  )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _AuctionThumbnail(imageUrl: v.imageUrl?.url ?? ''),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white, size: 20),
                      onPressed: () {},
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
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(v.regno ?? '-',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
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
                            color: Colors.black54),
                      ),
                    ],
                  ),
                  Text(title.isNotEmpty ? title : 'Vehicle',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  if (specs.isNotEmpty)
                    Text(specs,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    v.lenderName ?? '',
                    style: const TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 16,
                              color: _ended ? Colors.red : Colors.black87),
                          const SizedBox(width: 4),
                          Text(
                            _ended ? 'Ended' : _fmt(_remaining),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _ended ? Colors.red : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Base price: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: _formatPrice(v.basePrice?.toInt()),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Current Bid: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _ended ? null : _openBidSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3E5F5),
                            foregroundColor: const Color(0xFF6200EE),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Auto bid',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _ended ? null : _openBidSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F00E6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Bid',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
