// lib/features/live_auction/presentation/pages/auction_homepage.dart

import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/vehicle_item_mapper.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AuctionHomePage extends ConsumerStatefulWidget {
  final String eventId;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final String? initialMode;
  final int? lenderId;
  final bool isUpcoming;

  const AuctionHomePage({
    super.key,
    required this.eventId,
    this.initialFromDate,
    this.initialToDate,
    this.initialMode,
    this.lenderId,
    this.isUpcoming = false,
  });

  @override
  ConsumerState<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends ConsumerState<AuctionHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchVehicles());
  }

  Future<void> _fetchVehicles() async {
    if (widget.isUpcoming) {
      // ── UPCOMING ALONE: Hits https://dev.k99x.com/servlet/admin/live/auction/json ──
      // final fromStr = widget.initialFromDate != null
      //     ? DateFormat('yyyy-MM-dd').format(widget.initialFromDate!)
      //     : null;
      // final toStr = widget.initialToDate != null
      //     ? DateFormat('yyyy-MM-dd').format(widget.initialToDate!)
      //     : null;

      final params = LiveAuctionParams(
        status: 'UPCOMING',
        lenderId: widget.lenderId,
        fromDate: widget.initialFromDate,
        toDate: widget.initialToDate,
        // mode: widget.initialMode,
      );

      await ref.read(liveAuctionNotifier.notifier).getLiveAuctions(params);
    } else {
      // ── NORMAL / LIVE LOTS: Hits /servlet/api/dealer/events/live/{eventId}/vehicles ──
      await ref
          .read(eventVehiclesNotifierProvider.notifier)
          .fetchEventVehicles(widget.eventId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(LiveAuctionModel v, String query) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();

    final make = (v.make ?? '').toLowerCase();
    final model = (v.model ?? '').toLowerCase();
    final variant = (v.variant ?? '').toLowerCase();
    final regno = (v.regno ?? '').toLowerCase();
    final lotNo = (v.lotNo ?? '').toLowerCase();

    return make.contains(q) ||
        model.contains(q) ||
        variant.contains(q) ||
        regno.contains(q) ||
        lotNo.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isUpcoming ? 'Upcoming Vehicles' : 'Auction Vehicles',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search make, model, variant, lot no...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12.5,
                          ),
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
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Vehicle Listing
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _fetchVehicles,
                child: widget.isUpcoming
                    ? _buildUpcomingList()
                    : _buildLiveEventVehiclesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Render Upcoming API results (List<LiveAuctionModel>) ──────────
  Widget _buildUpcomingList() {
    final state = ref.watch(liveAuctionNotifier);

    return state.when(
      initial: () => const LiveAuctionListSkeleton(),
      loading: () => const LiveAuctionListSkeleton(),
      error: (msg) => _ErrorView(message: msg, onRetry: _fetchVehicles),
      data: (vehicles) {
        final filtered =
            vehicles.where((v) => _matchesSearch(v, _searchQuery)).toList();

        if (filtered.isEmpty) {
          return _EmptyStateView(
            icon: Icons.directions_car_filled_outlined,
            title: 'No Upcoming Vehicles',
            subtitle: _searchQuery.isNotEmpty
                ? 'No upcoming vehicles matching "$_searchQuery".'
                : 'No upcoming vehicles scheduled for this lender and date range.',
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            return LiveAuctionCard(
              vehicle: filtered[i],
              isUpcoming: true,
            );
          },
        );
      },
    );
  }

  // ── Render Normal Event Vehicles (EventVehiclesResponse) ──────────
  Widget _buildLiveEventVehiclesList() {
    final state = ref.watch(eventVehiclesNotifierProvider);

    return state.when(
      initial: () => const LiveAuctionListSkeleton(),
      loading: () => const LiveAuctionListSkeleton(),
      error: (msg) => _ErrorView(message: msg, onRetry: _fetchVehicles),
      data: (response) {
        final items = response.data?.liveVehicles ?? [];
        final models = items.map((item) => item.toLiveAuctionModel()).toList();
        final filtered =
            models.where((v) => _matchesSearch(v, _searchQuery)).toList();

        if (filtered.isEmpty) {
          return _EmptyStateView(
            icon: Icons.directions_car_filled_outlined,
            title: 'No Vehicles Found',
            subtitle: _searchQuery.isNotEmpty
                ? 'No vehicles matching "$_searchQuery".'
                : 'No vehicles available in this auction event.',
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            return LiveAuctionCard(
              vehicle: filtered[i],
              isUpcoming: false,
            );
          },
        );
      },
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
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 10),
              Text(
                message.isNotEmpty ? message : 'Failed to load vehicles',
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
