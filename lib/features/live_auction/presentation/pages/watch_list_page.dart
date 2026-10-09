// lib/features/watchlist/presentation/pages/watchlist_page.dart

import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(watchlistNotifierProvider.notifier).fetchWatchlist();
    });
  }

  /// Extracts the valid image URL from the nested Watchlist vehicle image structure
  String? _extractImageUrl(WatchlistVehicleItem item) {
    if (item.frontImage != null && item.frontImage!.trim().startsWith('http')) {
      return item.frontImage!.trim();
    }

    final imgs = item.vehicleImages;
    if (imgs != null) {
      // 1. Check allImageUrls list
      if (imgs.allImageUrls != null && imgs.allImageUrls!.isNotEmpty) {
        final first = imgs.allImageUrls!.first?.toString().trim();
        if (first != null && first.startsWith('http')) return first;
      }

      // 2. Check imagesAsList
      if (imgs.imagesAsList != null && imgs.imagesAsList!.isNotEmpty) {
        for (final entry in imgs.imagesAsList!) {
          if (entry is Map && entry['url'] != null) {
            final u = entry['url'].toString().trim();
            if (u.startsWith('http')) return u;
          }
        }
      }

      // 3. Check frontView if parsed as URL string
      if (imgs.frontView != null && imgs.frontView!.trim().startsWith('http')) {
        return imgs.frontView!.trim();
      }
    }
    return null;
  }

  /// Converts WatchlistVehicleItem to LiveAuctionModel, enriched by LiveAuction data if present
  LiveAuctionModel _toLiveAuctionModel(
    WatchlistVehicleItem item,
    List<LiveAuctionModel> liveAuctions,
  ) {
    final v = item.vehicle;
    final a = item.auction;

    // Find full auction item if it is loaded in the live auction cache
    LiveAuctionModel? match;
    try {
      match = liveAuctions.firstWhere(
        (m) => m.vehicleId != null && m.vehicleId == v?.vehicleId,
      );
    } catch (_) {
      match = null;
    }

    // Convert epoch milliseconds to ISO-8601 string for LiveAuctionCard timer
    String? closeDt;
    if (a?.endTime != null) {
      closeDt = DateTime.fromMillisecondsSinceEpoch(a!.endTime!)
          .toIso8601String()
          .replaceFirst('T', ' ');
    } else {
      closeDt = match?.auctionCloseDt;
    }

    // Resolve Image URL
    final imageUrl = _extractImageUrl(item) ?? match?.imageUrl?.url;

    return LiveAuctionModel(
      vehicleId: v?.vehicleId ?? match?.vehicleId,
      make: (v?.make?.isNotEmpty ?? false) ? v?.make : match?.make,
      model: (v?.model?.isNotEmpty ?? false) ? v?.model : match?.model,
      variant: (v?.variant?.isNotEmpty ?? false) ? v?.variant : match?.variant,
      mfgYear: (v?.mfgYear?.isNotEmpty ?? false) ? v?.mfgYear : match?.mfgYear,
      regno: (v?.regno?.isNotEmpty ?? false) ? v?.regno : match?.regno,
      fuel: v?.fuel ?? match?.fuel,
      cityName: v?.city ?? match?.cityName,
      stateName: v?.state ?? match?.stateName,
      kmsDriven: v?.kmsDriven ?? match?.kmsDriven,
      ownerCount: v?.ownerCount ?? match?.ownerCount,
      basePrice:
          v?.basePrice ?? a?.basePrice ?? a?.startingPrice ?? match?.basePrice,
      status: a?.status ?? v?.status ?? match?.status ?? 'LIVE',
      auctionCloseDt: closeDt,
      lenderName: (match?.lenderName != null && match!.lenderName!.isNotEmpty)
          ? match.lenderName
          : (v?.lenderId != null && v!.lenderId! > 0
              ? 'Lender #${v.lenderId}'
              : 'Auction'),
      imageUrl: imageUrl != null && imageUrl.isNotEmpty
          ? VehicleImageModelF(url: imageUrl)
          : null,
      bids: a?.currentPrice != null
          ? [BidsModel(amount: a!.currentPrice!)]
          : (match?.bids ??
              (a?.startingPrice != null
                  ? [BidsModel(amount: a!.startingPrice!)]
                  : [])),
    );
  }

  /// Removes duplicate vehicles based on unique vehicleId
  List<WatchlistVehicleItem> _deduplicateVehicles(
      List<WatchlistVehicleItem> items) {
    final seenIds = <String>{};
    final uniqueItems = <WatchlistVehicleItem>[];

    for (final item in items) {
      final id = item.vehicle?.vehicleId ?? '';
      if (id.isNotEmpty && !seenIds.contains(id)) {
        seenIds.add(id);
        uniqueItems.add(item);
      }
    }
    return uniqueItems;
  }

  @override
  Widget build(BuildContext context) {
    final watchlistState = ref.watch(watchlistNotifierProvider);

    // Watch live auctions to merge richer data
    final liveAuctions = ref.watch(liveAuctionNotifier).maybeWhen(
          data: (list) => list,
          orElse: () => const <LiveAuctionModel>[],
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: watchlistState.when(
        initial: () => const LiveAuctionListSkeleton(),
        loading: () => const LiveAuctionListSkeleton(),
        error: (msg) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  msg.isNotEmpty ? msg : 'Failed to load watchlist',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(watchlistNotifierProvider.notifier)
                      .fetchWatchlist(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          final uniqueList = _deduplicateVehicles(items);

          if (uniqueList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 54,
                    color: Color(0xFFBFC2CC),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No vehicles in your watchlist',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap the heart icon on any vehicle to add it here',
                    style: TextStyle(color: Color(0xFF9AA0A6), fontSize: 12.5),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(watchlistNotifierProvider.notifier)
                  .fetchWatchlist();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: uniqueList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final auctionModel = _toLiveAuctionModel(
                  uniqueList[index],
                  liveAuctions,
                );
                return LiveAuctionCard(vehicle: auctionModel);
              },
            ),
          );
        },
      ),
    );
  }
}
