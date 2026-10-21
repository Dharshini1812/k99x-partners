// lib/features/profile/presentation/pages/my_bids_page.dart

import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/live_auction/data/model/new_auction_detail_model.dart';
import 'package:dealer/features/live_auction/data/model/vehicle_item_mapper.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBidsPage extends ConsumerStatefulWidget {
  const MyBidsPage({super.key});

  @override
  ConsumerState<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends ConsumerState<MyBidsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 3 filters: ALL, WINNING, OUTBID
  String _selectedHistoryFilter = 'ALL';
  static const _historyFilters = ['ALL', 'WINNING', 'OUTBID'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    Future.microtask(() => _fetchInitial());
  }

  Future<void> _fetchInitial() async {
    await Future.wait([
      ref.read(activeBidsNotifierProvider.notifier).fetchActiveBids(),
      ref.read(bidHistoryNotifierProvider.notifier).fetchBidHistory(),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// De-duplicates vehicle items by vehicleId
  List<VehicleItem> _deduplicateVehicles(List<VehicleItem> items) {
    final Map<String, VehicleItem> uniqueMap = {};
    for (final item in items) {
      final id = item.vehicle?.vehicleId?.trim() ??
          item.auction?.vehicleId?.trim() ??
          '';
      if (id.isNotEmpty) {
        uniqueMap[id] = item;
      }
    }
    return uniqueMap.values.toList();
  }

  /// Searches across make, model, variant, and regno
  bool _matchesSearch(VehicleItem item, String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();

    final v = item.vehicle;
    final make = (v?.make ?? '').toLowerCase();
    final model = (v?.model ?? '').toLowerCase();
    final variant = (v?.variant ?? '').toLowerCase();
    final regno = (v?.regno ?? item.auction?.regno ?? '').toLowerCase();

    return make.contains(q) ||
        model.contains(q) ||
        variant.contains(q) ||
        regno.contains(q);
  }

  /// Resolves the status strictly from vehicle.status
  String _resolveStatus(VehicleItem item) {
    final rawStatus = item.vehicle?.status ?? item.status ?? '';
    return rawStatus.trim().toUpperCase();
  }

  bool _isItemWinning(VehicleItem item) {
    return _resolveStatus(item) == 'SOLD';
  }

  bool _isItemOutbid(VehicleItem item) {
    return _resolveStatus(item) == 'UNSOLD';
  }

  String _resolveBadge(VehicleItem item) {
    if (_isItemWinning(item)) return 'WINNING';
    if (_isItemOutbid(item)) return 'OUTBID';
    return item.rank == 1 ? 'WINNING' : 'OUTBID';
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeBidsNotifierProvider);
    final historyState = ref.watch(bidHistoryNotifierProvider);

    final activeCount = activeState.maybeWhen(
      loaded: (res) => _deduplicateVehicles(res.data?.bids ?? []).length,
      orElse: () => 0,
    );

    final historyCount = historyState.maybeWhen(
      loaded: (res) => _deduplicateVehicles(res.data?.bids ?? []).length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bids',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.24),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Active Bids'),
                      const SizedBox(width: 6),
                      _CountBadge(
                        count: activeCount,
                        isActive: _tabController.index == 0,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Bid History'),
                      const SizedBox(width: 6),
                      _CountBadge(
                        count: historyCount,
                        isActive: _tabController.index == 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF94A3B8), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: 'Search make, model, variant, reg no...',
                          hintStyle: TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 12.5),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.cancel_rounded,
                            size: 16, color: Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
            ),

            // Tabs Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── TAB 1: ACTIVE BIDS ───────────────────────────────
                  RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref
                        .read(activeBidsNotifierProvider.notifier)
                        .fetchActiveBids(),
                    child: activeState.when(
                      initial: () => const LiveAuctionListSkeleton(),
                      loading: () => const LiveAuctionListSkeleton(),
                      error: (msg) => _ErrorView(
                        message: msg,
                        onRetry: () => ref
                            .read(activeBidsNotifierProvider.notifier)
                            .fetchActiveBids(),
                      ),
                      loaded: (response) {
                        final rawBids = response.data?.bids ?? [];
                        final uniqueBids = _deduplicateVehicles(rawBids);
                        final displayBids = uniqueBids
                            .where((b) => _matchesSearch(b, _searchQuery))
                            .toList();

                        if (displayBids.isEmpty) {
                          return _EmptyStateView(
                            icon: Icons.gavel_rounded,
                            title: 'No Active Bids',
                            subtitle: _searchQuery.isNotEmpty
                                ? 'No active bids matching "$_searchQuery".'
                                : 'Vehicles you are currently bidding on will appear here.',
                          );
                        }

                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: displayBids.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final item = displayBids[i];
                            final liveAuction = item.toLiveAuctionModel();
                            return LiveAuctionCard(
                              vehicle: liveAuction,
                              isBidHistory: false,
                              statusBadge: _resolveBadge(item),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ── TAB 2: BID HISTORY ───────────────────────────────
                  historyState.when(
                    initial: () => const LiveAuctionListSkeleton(),
                    loading: () => const LiveAuctionListSkeleton(),
                    error: (msg) => _ErrorView(
                      message: msg,
                      onRetry: () => ref
                          .read(bidHistoryNotifierProvider.notifier)
                          .fetchBidHistory(),
                    ),
                    loaded: (response) {
                      final rawBids = response.data?.bids ?? [];
                      final uniqueBids = _deduplicateVehicles(rawBids);

                      // Status filtering: ALL, WINNING (SOLD), OUTBID (UNSOLD)
                      final statusFilteredBids = uniqueBids.where((bid) {
                        if (_selectedHistoryFilter == 'ALL') {
                          return true;
                        } else if (_selectedHistoryFilter == 'WINNING') {
                          return _isItemWinning(bid);
                        } else {
                          return _isItemOutbid(bid);
                        }
                      }).toList();

                      final displayBids = statusFilteredBids
                          .where((b) => _matchesSearch(b, _searchQuery))
                          .toList();

                      final totalCount = uniqueBids.length;
                      final winningCount =
                          uniqueBids.where(_isItemWinning).length;
                      final outbidCount =
                          uniqueBids.where(_isItemOutbid).length;

                      return Column(
                        children: [
                          Container(
                            height: 48,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Row(
                              children: _historyFilters.map((status) {
                                final isSelected =
                                    _selectedHistoryFilter == status;
                                final count = status == 'ALL'
                                    ? totalCount
                                    : (status == 'WINNING'
                                        ? winningCount
                                        : outbidCount);

                                Color selectedColor = AppColors.primary;
                                if (status == 'WINNING') {
                                  selectedColor = const Color(0xFF10B981);
                                } else if (status == 'OUTBID') {
                                  selectedColor = const Color(0xFFEF4444);
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.25)
                                                : Colors.black12,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$count',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    selected: isSelected,
                                    selectedColor: selectedColor,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    side: BorderSide(
                                      color: isSelected
                                          ? selectedColor
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onSelected: (_) {
                                      setState(() =>
                                          _selectedHistoryFilter = status);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: () => ref
                                  .read(bidHistoryNotifierProvider.notifier)
                                  .fetchBidHistory(),
                              child: displayBids.isEmpty
                                  ? _EmptyStateView(
                                      icon: Icons.history_rounded,
                                      title: 'No Results Found',
                                      subtitle: _searchQuery.isNotEmpty
                                          ? 'No vehicles matching "$_searchQuery".'
                                          : 'No vehicles found in $_selectedHistoryFilter.',
                                    )
                                  : ListView.separated(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 10, 16, 24),
                                      itemCount: displayBids.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, i) {
                                        final item = displayBids[i];
                                        final liveAuction =
                                            item.toLiveAuctionModel();
                                        return LiveAuctionCard(
                                          vehicle: liveAuction,
                                          isBidHistory: true,
                                          statusBadge: _resolveBadge(item),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
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

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isActive;

  const _CountBadge({required this.count, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.24) : Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isActive ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 44, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(
                message.isNotEmpty ? message : 'Failed to load bids',
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
