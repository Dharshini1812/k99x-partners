// lib/features/live_auction/presentation/pages/vehicle_detail_page.dart

import 'dart:async';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/pages/inspection_full_image_viewer_page.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/place_bid_sheet.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';
import 'package:dealer/features/trial/presentation/widgets/trial_blocked_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectionIssueModel {
  final String title;
  final String description;
  final String imageUrl;
  final String category;

  const InspectionIssueModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  });
}

class VehicleDetailPage extends ConsumerStatefulWidget {
  final LiveAuctionModel vehicle;
  final String vehicleId;
  const VehicleDetailPage({
    super.key,
    required this.vehicleId,
    required this.vehicle,
  });

  @override
  ConsumerState<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends ConsumerState<VehicleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _anchorKey = GlobalKey();
  double _biddingBarHeight = 135.0;

  bool _showBackToTop = false;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  static const int _minAboveBasePrice = 10000;
  static const int _minIncrement = 1000;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 300 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });

    Future.microtask(() {
      ref
          .read(vehicleDetailProvider.notifier)
          .fetchVehicleDetail(widget.vehicleId);
    });
  }

  @override
  void didUpdateWidget(covariant VehicleDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleId != widget.vehicleId) {
      _timer?.cancel();
      _timer = null;
      _ended = false;
      _remaining = Duration.zero;
      ref
          .read(vehicleDetailProvider.notifier)
          .fetchVehicleDetail(widget.vehicleId);
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleWatchlist(bool isCurrentlyWatchlisted) async {
    final targetId = widget.vehicleId;
    if (targetId.isEmpty) return;

    final success = await ref
        .read(watchlistUpdateNotifierProvider.notifier)
        .updateWatchlist(vehicleId: targetId, add: !isCurrentlyWatchlisted);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update watchlist')),
      );
    }
  }

  Future<void> _openBidSheet(BidSheetMode mode) async {
    final user = ref.read(dLogic).user;
    final trial = ref.read(trialLogic);

    if (user == null && trial.isTrialSession) {
      showTrialBlockedDialog(context, ref, expired: trial.isTrialExpired);
      return;
    }

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceBidSheet(vehicle: widget.vehicle, mode: mode),
    );

    if (result != null && mounted) {
      ref.read(auctionLogic).search();
    }
  }

  void _startTimer(int? endTimeMs) {
    if (_timer != null) return;
    if (endTimeMs == null) {
      setState(() => _ended = true);
      return;
    }
    final end = DateTime.fromMillisecondsSinceEpoch(endTimeMs);
    void tick() {
      final diff = end.difference(DateTime.now());
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

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  String _fmtTimer(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _fmtPrice(num? amount) {
    if (amount == null) return '₹--';
    final s = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0 && posFromRight % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₹$buf';
  }

  num _minimumBid(num currentBid, num basePrice) {
    final baseFloor = basePrice + _minAboveBasePrice;
    if (currentBid <= 0) return baseFloor;
    final topFloor = currentBid + _minIncrement;
    return topFloor > baseFloor ? topFloor : baseFloor;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openVehicleImageViewer(List<VehicleImage> images, int index) {
    if (images.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InspectionFullImageViewerPage(
          vehicleTitle: 'Vehicle Photos',
          initialIndex: index,
          items: images
              .map((e) => FullImageViewerItem(
                    imageUrl: e.url ?? '',
                    title: e.label ?? '',
                    category: e.type ?? 'Vehicle',
                  ))
              .toList(),
        ),
      ),
    );
  }

  List<LiveAuctionModel> _findSimilarVehicles(List<LiveAuctionModel> all) {
    final curMake = (widget.vehicle.make ?? '').trim().toLowerCase();
    final curModel = (widget.vehicle.model ?? '').trim().toLowerCase();

    return all.where((item) {
      if (item.vehicleId == widget.vehicle.vehicleId) return false;
      final m = (item.make ?? '').trim().toLowerCase();
      final mo = (item.model ?? '').trim().toLowerCase();

      final matchesMake = curMake.isNotEmpty && m == curMake;
      final matchesModel = curModel.isNotEmpty && mo == curModel;
      return matchesMake || matchesModel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleDetailProvider);

    final allAuctions = ref.watch(liveAuctionNotifier).maybeWhen(
          data: (list) => list,
          orElse: () => const <LiveAuctionModel>[],
        );
    final similarVehicles = _findSimilarVehicles(allAuctions);

    // Dynamic Watchlist resolution by matching vehicle ID
    final watchlistState = ref.watch(watchlistNotifierProvider);
    final isWatchlisted = watchlistState.maybeWhen(
      data: (items) =>
          items.any((item) => item.vehicle?.vehicleId == widget.vehicleId),
      orElse: () => false,
    );

    return state.when(
      initial: () => const VehicleDetailSkeleton(),
      loading: () => const VehicleDetailSkeleton(),
      error: (msg) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(msg.isNotEmpty ? msg : 'Failed to load vehicle details',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(vehicleDetailProvider.notifier)
                      .fetchVehicleDetail(widget.vehicleId),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      loaded: (response) {
        final detail = response.data;
        if (detail == null) {
          return const Scaffold(
              body: Center(child: Text('No details available')));
        }

        final v = detail.vehicle;
        final auction = detail.auction;

        if (_timer == null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _startTimer(auction?.endTime));
        }

        final title = [v?.mfgYear, v?.make, v?.model, v?.variant]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        final displayTitle = title.isNotEmpty ? title : 'Vehicle';

        final currentBid = detail.highestBidAmount;
        final basePrice = v?.basePrice ?? 0;
        final nextBid = _minimumBid(currentBid, basePrice);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              displayTitle,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black87),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  isWatchlisted ? Icons.favorite : Icons.favorite_border,
                  color:
                      isWatchlisted ? const Color(0xFFE74C3C) : Colors.black87,
                ),
                onPressed: () => _toggleWatchlist(isWatchlisted),
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildImageHeader(
                      v?.regno ?? '', v?.rtoCode, v?.rtoName, detail.images),
                  const SizedBox(height: 10),
                  _buildVehicleOverview(
                    displayTitle,
                    v?.mfgYear,
                    v?.fuel,
                    v?.transmissionType,
                    v?.kmsDriven,
                    v?.ownerCount,
                    isWatchlisted,
                  ),
                  const SizedBox(height: 5),
                  _buildRatingBadges(),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Documents',
                    trailing: const Icon(Icons.info_outline,
                        size: 20, color: Colors.grey),
                    children: [
                      _buildKeyValueRow(
                          'RC availability', v?.rcStatus ?? 'N/A'),
                      _buildKeyValueRow(
                        'Insurance',
                        v?.insuranceStatus ?? 'N/A',
                        valueColor:
                            (v?.insuranceStatus?.toLowerCase() == 'expired')
                                ? Colors.redAccent
                                : Colors.teal,
                      ),
                      _buildKeyValueRow('Road tax paid', v?.roadtax ?? 'N/A',
                          valueColor: Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    title: 'Other information',
                    children: [
                      _buildKeyValueRow(
                          'Duplicate key', v?.duplicateKey ?? 'N/A'),
                      _buildKeyValueRow(
                          'Chassis number', v?.chassisNo ?? 'N/A'),
                      _buildKeyValueRow('Engine number', v?.engineNo ?? 'N/A'),
                      _buildKeyValueRow(
                          'Hypothecation', v?.hypothecation ?? 'N/A'),
                      if ((v?.hypothecationBank ?? '').isNotEmpty)
                        _buildKeyValueRow(
                            'Hypothecation bank', v!.hypothecationBank!),
                      _buildKeyValueRow(
                          'Pollution Norm', v?.pollutionForm ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSectionCard(
                    title: 'Registration and fitness',
                    children: [
                      _buildKeyValueRow(
                          'Manufacturing date', v?.mfgYear ?? 'N/A'),
                      _buildKeyValueRow('RTO code', v?.rtoCode ?? 'N/A'),
                      _buildKeyValueRow('RTO name', v?.rtoName ?? 'N/A'),
                      _buildKeyValueRow(
                          'Fitness report', v?.fitnesReport ?? 'N/A',
                          valueColor: Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInspectionDetails(detail.images),

                  // Anchor reserving height for bottom bidding sheet
                  SizedBox(
                    key: _anchorKey,
                    height: detail.biddingAllowed ? _biddingBarHeight : 0,
                  ),

                  // More Like This section
                  if (similarVehicles.isNotEmpty)
                    _buildMoreLikeThisSection(similarVehicles),
                ],
              ),

              // Bidding Bar (Sticky at bottom, shifts upward once anchor scrolls past)
              if (detail.biddingAllowed)
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    double bottomOffset = 0;
                    if (_anchorKey.currentContext != null) {
                      final renderBox = _anchorKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (renderBox != null && renderBox.hasSize) {
                        final pos = renderBox.localToGlobal(Offset.zero);
                        final screenH = MediaQuery.of(context).size.height;
                        final threshold = screenH - renderBox.size.height;
                        final diff = threshold - pos.dy;
                        if (diff > 0) {
                          bottomOffset = diff;
                        }
                      }
                    }
                    return Positioned(
                      bottom: bottomOffset,
                      left: 0,
                      right: 0,
                      child: child!,
                    );
                  },
                  child: _MeasuredWidget(
                    onSizeChanged: (size) {
                      if (size.height != _biddingBarHeight && mounted) {
                        setState(() {
                          _biddingBarHeight = size.height;
                        });
                      }
                    },
                    child: _buildBiddingBottomBar(
                      currentBid: currentBid,
                      basePrice: basePrice,
                      nextBid: nextBid,
                    ),
                  ),
                ),

              // Floating "Go to top" button shifts smoothly with the bidding bar
              if (_showBackToTop)
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    double extraShift = 0;
                    if (_anchorKey.currentContext != null) {
                      final renderBox = _anchorKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (renderBox != null && renderBox.hasSize) {
                        final pos = renderBox.localToGlobal(Offset.zero);
                        final screenH = MediaQuery.of(context).size.height;
                        final threshold = screenH - renderBox.size.height;
                        final diff = threshold - pos.dy;
                        if (diff > 0) {
                          extraShift = diff;
                        }
                      }
                    }
                    return Positioned(
                      bottom: 140 + extraShift,
                      left: 0,
                      right: 0,
                      child: Center(child: child),
                    );
                  },
                  child: GestureDetector(
                    onTap: _scrollToTop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2D35),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward,
                              size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text('GO TO TOP',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreLikeThisSection(List<LiveAuctionModel> vehicles) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'More Like This',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6200EE).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vehicles.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6200EE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = vehicles[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleDetailPage(
                        vehicleId: item.vehicleId ?? '',
                        vehicle: item,
                      ),
                    ),
                  );
                },
                child: IgnorePointer(
                  child: LiveAuctionCard(vehicle: item),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  VehicleImage? _frontImage(List<VehicleImage> images) {
    if (images.isEmpty) return null;
    for (final img in images) {
      if ((img.type ?? '').toLowerCase() == 'front_view') return img;
    }
    return images.first;
  }

  Widget _buildImageHeader(String vehicleId, String? rtoCode, String? rtoName,
      List<VehicleImage> images) {
    final hero = _frontImage(images);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 280,
                width: double.infinity,
                child: hero == null || (hero.url ?? '').isEmpty
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.directions_car,
                            size: 90, color: Colors.grey),
                      )
                    : GestureDetector(
                        onTap: () => _openVehicleImageViewer(
                            images, images.indexOf(hero)),
                        child: Image.network(
                          hero.url!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.directions_car,
                                size: 90, color: Colors.grey),
                          ),
                        ),
                      ),
              ),
              if (images.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${images.length} photo${images.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.view_in_ar,
                      color: Colors.white, size: 18),
                ),
              ),
              if (hero?.label != null && hero!.label!.isNotEmpty)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      hero.label!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final img = images[index];
                  final isHero = img == hero;
                  return GestureDetector(
                    onTap: () => _openVehicleImageViewer(images, index),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHero
                              ? const Color(0xFF4C3BCF)
                              : Colors.grey.shade300,
                          width: isHero ? 2 : 1,
                        ),
                        color: Colors.grey.shade200,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (img.url ?? '').isEmpty
                          ? const Icon(Icons.image,
                              size: 20, color: Colors.grey)
                          : Image.network(
                              img.url!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  size: 20,
                                  color: Colors.grey),
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (rtoCode != null && rtoCode.isNotEmpty) _buildTag(rtoCode),
                if (rtoCode != null && rtoCode.isNotEmpty)
                  const SizedBox(width: 6),
                if (rtoName != null && rtoName.isNotEmpty) _buildTag(rtoName),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black87)),
    );
  }

  Widget _buildVehicleOverview(
    String title,
    String? mfgYear,
    String? fuel,
    String? transmission,
    int? kms,
    int? owners,
    bool isWatchlisted,
  ) {
    final specs = [
      fuel,
      transmission,
      kms != null ? '${kms}k km' : null,
      owners != null
          ? '${owners == 1 ? '1st' : owners == 2 ? '2nd' : '${owners}th'} Owner'
          : null,
    ].where((e) => e != null && e.isNotEmpty).join('  •  ');

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ' $title'.trim(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: () => _toggleWatchlist(isWatchlisted),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isWatchlisted
                          ? const Color(0xFFE74C3C).withOpacity(0.4)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isWatchlisted
                        ? const Color(0xFFE74C3C).withOpacity(0.08)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    isWatchlisted ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isWatchlisted
                        ? const Color(0xFFE74C3C)
                        : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () async {
                  if (widget.vehicle.vehReport == null) return;
                  final uri = Uri.parse(widget.vehicle.vehReport!);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(specs.isNotEmpty ? specs : '-',
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRatingBadges() {
    final ratings = [
      {'title': 'Exterior', 'score': 'NA'},
      {'title': 'Engine', 'score': 'NA'},
      {'title': 'AC', 'score': 'NA'},
      {'title': 'Electricals', 'score': 'NA'},
      {'title': 'Steering', 'score': 'NA'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.assignment, color: Color(0xFF5B4DFF), size: 24),
          ...ratings.map((r) => Column(
                children: [
                  Text(r['title']!,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1CB098),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(r['score']!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required List<Widget> children,
      Widget? trailing}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildInspectionDetails(List<VehicleImage> images) {
    String? thumbFor(int i) =>
        images.isEmpty ? null : images[i % images.length].url;
    VoidCallback tapFor(int i) => () =>
        _openVehicleImageViewer(images, images.isEmpty ? 0 : i % images.length);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exterior',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Structure',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          _buildPassedItem(
              'Apron, Dickey, Pillar, Cowl top, Right quarter panel'),
          _buildClickableIssueItem(
              title: 'Left quarter panel',
              subtitle: 'Scratch, Repainted',
              thumbnailUrl: thumbFor(0),
              onTap: tapFor(0)),
          _buildClickableIssueItem(
              title: 'Front left leg',
              subtitle: 'Surface level rust',
              thumbnailUrl: thumbFor(1),
              onTap: tapFor(1)),
          const Divider(height: 24),
          const Text('Exterior panels',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          _buildPassedItem('Roof, Bonnet, Dickey door, Right fender'),
          _buildClickableIssueItem(
              title: 'Rear bumper',
              subtitle: 'Scratch',
              thumbnailUrl: thumbFor(2),
              onTap: tapFor(2)),
          _buildClickableIssueItem(
              title: 'Front bumper',
              subtitle: 'Scratch, Repainted',
              thumbnailUrl: thumbFor(3),
              onTap: tapFor(3)),
          _buildClickableIssueItem(
              title: 'Left fender',
              subtitle: 'Repainted',
              thumbnailUrl: thumbFor(4),
              onTap: tapFor(4)),
          _buildClickableIssueItem(
              title: 'Rear left door',
              subtitle: 'Dent, Scratch',
              thumbnailUrl: thumbFor(5),
              onTap: tapFor(5)),
          _buildClickableIssueItem(
              title: 'Rear right door',
              subtitle: 'Scratch',
              thumbnailUrl: thumbFor(6),
              onTap: tapFor(6)),
          const Divider(height: 24),
          const Text('Tyres',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          _buildClickableIssueItem(
              title: 'Front left tyre',
              subtitle: '35% integrity',
              thumbnailUrl: thumbFor(7),
              onTap: tapFor(7)),
          _buildClickableIssueItem(
              title: 'Front right tyre',
              subtitle: '',
              thumbnailUrl: thumbFor(8),
              onTap: tapFor(8)),
          const Divider(height: 24),
          const Text('Other components',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          _buildPassedItem(
              'Fire wall, Lower member, Right running board, Headlight supports, Upper member (bonnet patti)'),
          _buildClickableIssueItem(
              title: 'Dickey',
              subtitle: 'Toolkit not available',
              thumbnailUrl: thumbFor(9),
              onTap: tapFor(9)),
          _buildClickableIssueItem(
              title: 'Left running board',
              subtitle: 'Dent',
              thumbnailUrl: thumbFor(10),
              onTap: tapFor(10)),
          const Divider(height: 24),
          const Text('Windshield & lights',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          _buildPassedItem('Svms, Headlights, Tail lights, Windshield'),
          _buildClickableIssueItem(
              title: 'Left tail light',
              subtitle: 'Crack',
              thumbnailUrl: thumbFor(11),
              onTap: tapFor(11)),
        ],
      ),
    );
  }

  Widget _buildPassedItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1CB098), size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildClickableIssueItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? thumbnailUrl,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
        child: Row(
          children: [
            const Icon(Icons.remove_circle, color: Color(0xFFE5A93C), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFEFEFEF),
              ),
              clipBehavior: Clip.antiAlias,
              child: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.photo_size_select_actual,
                          size: 16,
                          color: Colors.grey),
                    )
                  : const Icon(Icons.photo_size_select_actual,
                      size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiddingBottomBar({
    required num currentBid,
    required num basePrice,
    required num nextBid,
  }) {
    final placeBidState = ref.watch(placeBidNotifier);
    final autoBidState = ref.watch(autoBidNotifier);
    final isPlacingBid =
        placeBidState.maybeWhen(loading: () => true, orElse: () => false);
    final isEnablingAutobid =
        autoBidState.maybeWhen(loading: () => true, orElse: () => false);

    final trial = ref.watch(trialLogic);
    final user = ref.watch(dLogic).user;

    final isTrialLocked = (user == null) && trial.isTrialSession;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -2),
              blurRadius: 8),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTrialLocked)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: Color(0xFFB07B00)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "You're browsing in free trial — sign up to place bids",
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFB07B00),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 16, color: _ended ? Colors.red : Colors.black87),
                    const SizedBox(width: 4),
                    Text(
                      _ended ? 'Ended' : _fmtTimer(_remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _ended ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Base price ${_fmtPrice(basePrice)}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    Text('Current bid ${_fmtPrice(currentBid)}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Minimum next bid: ${_fmtPrice(nextBid)}',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _ended
                        ? null
                        : () => _openBidSheet(BidSheetMode.autobid),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: isTrialLocked
                              ? Colors.grey.shade300
                              : const Color(0xFFE8E5FF)),
                      backgroundColor: isTrialLocked
                          ? Colors.grey.shade100
                          : const Color(0xFFF2F0FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isEnablingAutobid
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isTrialLocked) ...[
                                Icon(Icons.lock_outline,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                              ],
                              Text('Auto bid',
                                  style: TextStyle(
                                      color: isTrialLocked
                                          ? Colors.grey.shade500
                                          : const Color(0xFF4C3BCF),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _ended ? null : () => _openBidSheet(BidSheetMode.bid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTrialLocked
                          ? Colors.grey.shade400
                          : const Color(0xFF4335DE),
                      disabledBackgroundColor: isTrialLocked
                          ? Colors.grey.shade400.withOpacity(0.6)
                          : const Color(0xFF4335DE).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: isPlacingBid
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white)),
                          )
                        : isTrialLocked
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline,
                                      size: 13, color: Colors.white70),
                                  SizedBox(width: 4),
                                  Text('Sign up to bid',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Bid',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  Text('at ${_fmtPrice(nextBid)}',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasuredWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChanged;
  const _MeasuredWidget({required this.child, required this.onSizeChanged});

  @override
  State<_MeasuredWidget> createState() => _MeasuredWidgetState();
}

class _MeasuredWidgetState extends State<_MeasuredWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSize());
  }

  void _checkSize() {
    if (!mounted) return;
    final size = context.size;
    if (size != null) {
      widget.onSizeChanged(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSize());
    return widget.child;
  }
}

class VehicleDetailSkeleton extends StatelessWidget {
  const VehicleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
              height: 230,
              width: double.infinity,
              color: Colors.white,
              child: Container(color: Colors.grey.shade200)),
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _box(width: 60, height: 60, radius: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 220, height: 18),
                const SizedBox(height: 10),
                _box(width: 160, height: 13),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  5, (i) => _box(width: 40, height: 28, radius: 12)),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCardSkeleton(rows: 3),
          const SizedBox(height: 10),
          _sectionCardSkeleton(rows: 5),
          const SizedBox(height: 10),
          _sectionCardSkeleton(rows: 4),
          const SizedBox(height: 10),
          _sectionCardSkeleton(rows: 6, titleWidth: 100),
        ],
      ),
    );
  }

  Widget _sectionCardSkeleton({required int rows, double titleWidth = 140}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: titleWidth, height: 15),
          const SizedBox(height: 14),
          for (int i = 0; i < rows; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _box(width: 100, height: 12),
                _box(width: 70, height: 12),
              ],
            ),
            if (i != rows - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _box(
      {required double width, required double height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
