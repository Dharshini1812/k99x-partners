// lib/features/live_auction/presentation/pages/auction_homepage.dart

import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/vehicle_item_mapper.dart';
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
    Future.microtask(() => _fetchVehicles());
  }

  Future<void> _fetchVehicles() async {
    if (widget.eventId != null && widget.eventId!.isNotEmpty) {
      await ref
          .read(eventVehiclesNotifierProvider.notifier)
          .fetchEventVehicles(widget.eventId!);
    }
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
    final eventVehiclesState = ref.watch(eventVehiclesNotifierProvider);
    final logic = ref.watch(auctionLogic);

    final bool isQuoteMode = widget.initialMode == '3' ||
        widget.initialMode?.toUpperCase() == 'QUOTE';

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
            // Search Input
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

            // Vehicle List View with Pull-To-Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchVehicles,
                color: AppColors.primary,
                child: eventVehiclesState.when(
                  initial: () => const LiveAuctionListSkeleton(),
                  loading: () => const LiveAuctionListSkeleton(),
                  error: (msg) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 40, color: Colors.redAccent),
                            const SizedBox(height: 8),
                            Text(
                              msg,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchVehicles,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  data: (response) {
                    final rawVehicles = widget.isUpcoming
                        ? (response.data?.closedVehicles ?? [])
                        : (response.data?.liveVehicles ?? []);

                    final auctions = rawVehicles
                        .map((item) => item.toLiveAuctionModel())
                        .where((a) => _matchesSearch(a, logic.searchQuery))
                        .toList();

                    if (auctions.isEmpty) {
                      final isSearching = logic.searchQuery.trim().isNotEmpty;
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
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
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      itemCount: auctions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final vehicle = auctions[i];
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
            ),
          ],
        ),
      ),
    );
  }
}
