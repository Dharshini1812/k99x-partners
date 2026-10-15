// lib/features/live_auction/presentation/pages/auction_homepage.dart

import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuctionHomePage extends ConsumerStatefulWidget {
  final String? eventId;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final int? lenderId;
  final String? initialMode;
  final bool isUpcoming;

  const AuctionHomePage({
    super.key,
    this.eventId,
    this.initialFromDate,
    this.initialToDate,
    this.lenderId,
    this.initialMode,
    this.isUpcoming = false,
  });

  @override
  ConsumerState<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends ConsumerState<AuctionHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(watchlistNotifierProvider.notifier).fetchWatchlist();
      final logic = ref.read(auctionLogic);

      // 1. Reset geographic filters
      logic.updateState(null);
      logic.updateCity(null);

      // 2. Set target status and preserve mode (mode='3' for Quote Price)
      final targetStatus = widget.isUpcoming ? 'UPCOMING' : 'LIVE';
      logic.setActiveTab(
        status: targetStatus,
        mode: widget.initialMode,
      );

      // 3. Set exact event date range
      if (widget.initialFromDate != null) {
        logic.updateFromDate(widget.initialFromDate);
      }
      if (widget.initialToDate != null) {
        logic.updateToDate(widget.initialToDate);
      }

      // 4. Lender filter: only assigned if explicitly requested
      if (widget.lenderId != null && widget.lenderId! > 0) {
        final lenders =
            ref.read(getLenderProvider).whenOrNull(data: (l) => l) ?? [];
        try {
          logic.selectedLender =
              lenders.firstWhere((l) => l.sno == widget.lenderId);
        } catch (_) {
          logic.selectedLender = null;
        }
      } else {
        logic.selectedLender = null;
      }

      // 5. Fire search API: ?mode=3&fromDate=YYYY-MM-DD&toDate=YYYY-MM-DD
      logic.search();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static bool _matchesSearch(LiveAuctionModel vehicle, String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    final haystack = [
      vehicle.make,
      vehicle.model,
      vehicle.variant,
      vehicle.regno,
      vehicle.vehicleId,
      vehicle.categoryName,
      vehicle.lenderName,
      vehicle.cityName,
      vehicle.stateName,
    ].where((e) => e != null).map((e) => e.toString().toLowerCase());
    return haystack.any((field) => field.contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final liveAuctionState = ref.watch(liveAuctionNotifier);
    final logic = ref.watch(auctionLogic);
    final bool isQuoteMode =
        widget.initialMode == '3' || widget.initialMode == 'QUOTE';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isUpcoming
              ? 'Upcoming Vehicles'
              : (isQuoteMode ? 'Quote Price Vehicles' : 'Available Vehicles'),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black45, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: logic.updateSearchQuery,
                        onSubmitted: (_) => logic.search(),
                        style: const TextStyle(fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Search reg no, vehicle, lender...',
                          hintStyle:
                              TextStyle(color: Colors.black45, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          logic.updateSearchQuery('');
                        },
                        child: const Icon(Icons.cancel_rounded,
                            size: 16, color: Colors.black38),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: liveAuctionState.when(
                initial: () => const LiveAuctionListSkeleton(),
                loading: () => const LiveAuctionListSkeleton(),
                error: (msg) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      msg,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (auctions) {
                  final filtered = auctions
                      .where((a) => _matchesSearch(a, logic.searchQuery))
                      .toList();

                  if (filtered.isEmpty) {
                    final isSearching = logic.searchQuery.trim().isNotEmpty;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSearching
                                ? Icons.search_off_rounded
                                : Icons.directions_car_rounded,
                            size: 42,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isSearching
                                ? 'No results for "${logic.searchQuery}"'
                                : 'No vehicles found in this event',
                            style: const TextStyle(
                                color: Colors.black45, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final vehicle = filtered[i];
                      return LiveAuctionCard(
                        vehicle: vehicle,
                        isUpcoming: widget.isUpcoming,
                        isQuotePrice: isQuoteMode,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
