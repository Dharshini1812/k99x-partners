// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/dashboard/data/model/d_stats_model.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/dashboard/presentation/logic/provider.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _kDark = Color(0xFF11142A);
const _kGrey = Color(0xFF9AA0A6);
const _kAccentBlue = Color(0xFF3B4EF5);
const _kBellBg = Color(0xFFEDEFFB);

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dStatsProvider.notifier).getDashboardStats();
      ref
          .read(myStockNotifierProvider.notifier)
          .getMyStock(offset: 0, limit: 20);
    });
  }

  int calculateWantedVehicleCount(VehicleResponse response) {
    final Map<String, int> wantedCounts = {};

    for (final vehicle in response.data) {
      final key = '${vehicle.make}_${vehicle.model}_${vehicle.variant}';
      if (!wantedCounts.containsKey(key)) {
        wantedCounts[key] = vehicle.wantedMatchCount ?? 0;
      }
    }

    return wantedCounts.values.fold(0, (sum, count) => sum + count);
  }

  int calculatePreApprovedLoanCount(VehicleResponse response) {
    return response.data.where((vehicle) {
      return vehicle.approvedLoanDetails != null &&
          vehicle.approvedLoanDetails!.trim().isNotEmpty;
    }).length;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dStatsProvider);
    final myStockAsync = ref.watch(myStockNotifierProvider);
    final logic = ref.watch(dLogic);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(dStatsProvider.notifier).getDashboardStats(),
              ref
                  .read(myStockNotifierProvider.notifier)
                  .getMyStock(offset: 0, limit: 20),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────
                _DashboardHeader(name: logic.user?.fullName ?? 'Partner'),

                const SizedBox(height: 24),

                // ── Stat Grid with Shimmer Skeleton ──────────────────────
                statsAsync.when(
                  initial: () => const _StatGridSkeleton(),
                  loading: () => const _StatGridSkeleton(),
                  error: (msg) => const _ErrorStateCard(
                    message: 'Could not load dashboard statistics',
                  ),
                  data: (statscount) => _StatGrid(
                    stats: statscount,
                    wantedVehicleCount: myStockAsync.maybeWhen(
                      data: (stock) => calculateWantedVehicleCount(stock),
                      orElse: () => 0,
                    ),
                    preApprovedLoanCount: myStockAsync.maybeWhen(
                      data: (stock) => calculatePreApprovedLoanCount(stock),
                      orElse: () => 0,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Stock by Age Header ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stock by Age',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(bottomNavIndexProvider.notifier).state = 2;
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: _kAccentBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Stock By Age Horizontal List with Skeleton ───────────
                myStockAsync.when(
                  initial: () => const _StockByAgeSkeleton(),
                  loading: () => const _StockByAgeSkeleton(),
                  error: (msg) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Unable to load recent stock',
                        style: TextStyle(color: _kGrey),
                      ),
                    ),
                  ),
                  data: (myStock) {
                    if (myStock.data.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No vehicles in stock yet',
                            style: TextStyle(color: _kGrey),
                          ),
                        ),
                      );
                    }
                    return _StockByAgeRow(myStock);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER — greeting, name, notification bell
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String name;
  const _DashboardHeader({required this.name});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 16) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: _kGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.isEmpty ? 'Partner' : name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: _kBellBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: _kAccentBlue,
                size: 24,
              ),
            ),
            Positioned(
              top: 12,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE85C5C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT GRID & SKELETON LOADER
// ─────────────────────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  final DashboardStats stats;
  final int wantedVehicleCount;
  final int preApprovedLoanCount;

  const _StatGrid({
    required this.stats,
    required this.wantedVehicleCount,
    required this.preApprovedLoanCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFE7E9FB),
                iconBg: const Color(0xFFC9CDF4),
                iconColor: const Color(0xFF2F3AA3),
                icon: Icons.directions_car_filled_rounded,
                value: stats.totalLiveVehicles ?? 0,
                label: 'LIVE STOCK',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFDFF5F0),
                iconBg: const Color(0xFFB8E7DC),
                iconColor: const Color(0xFF1E8C74),
                icon: Icons.layers_rounded,
                value: stats.totalVehicles ?? 0,
                label: 'MY STOCK',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFFCEFD3),
                iconBg: const Color(0xFFF6D89A),
                iconColor: const Color(0xFFB5750E),
                icon: Icons.verified_user_rounded,
                value: preApprovedLoanCount,
                label: 'PRE-APPROVED LOANS',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFEDEAFB),
                iconBg: const Color(0xFFD3CAF5),
                iconColor: const Color(0xFF6237C4),
                icon: Icons.search_rounded,
                value: wantedVehicleCount,
                label: 'WANTED VEHICLES',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFFBE3E3),
                iconBg: const Color(0xFFF3B9B9),
                iconColor: const Color(0xFFC13F3F),
                icon: Icons.sell_rounded,
                value: stats.totalSoldVehicles ?? 0,
                label: 'TOTAL SOLD VEHICLES',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFDCF1FB),
                iconBg: const Color(0xFFAEDFF5),
                iconColor: const Color(0xFF0E7CA8),
                icon: Icons.account_balance_wallet_rounded,
                value: stats.totalEarnings?.toInt() ?? 0,
                label: 'AVAILABLE FUND',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatGridSkeleton extends StatelessWidget {
  const _StatGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Row(
            children: [
              Expanded(child: _buildTileSkeleton()),
              const SizedBox(width: 14),
              Expanded(child: _buildTileSkeleton()),
            ],
          ),
          if (i < 2) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildTileSkeleton() {
    return Container(
      height: 135,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          const Spacer(),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 85,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final Color bg;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final int value;
  final String label;

  const _StatTile({
    required this.bg,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _kDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOCK BY AGE ROW & SKELETON
// ─────────────────────────────────────────────────────────────────────────────

class _StockByAgeRow extends StatelessWidget {
  final VehicleResponse data;
  const _StockByAgeRow(this.data);

  int _calculateAgeInDays(int? createdAt) {
    if (createdAt == null || createdAt == 0) return 0;
    final createdDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateTime.now().difference(createdDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: data.data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final stock = data.data[i];
          return _StockByAgeCard(
            name: stock.makeName ?? '',
            days: _calculateAgeInDays(stock.createdAt),
            imagePath:
                stock.dealerVehicleInspection?.frontVehicleImageUrl?.url ?? '',
            regNumber: stock.regNo ?? '',
          );
        },
      ),
    );
  }
}

class _StockByAgeSkeleton extends StatelessWidget {
  const _StockByAgeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Column(
          children: [
            Container(
              width: 58,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 76,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockByAgeCard extends StatelessWidget {
  final String name;
  final int days;
  final String regNumber;
  final String imagePath;

  const _StockByAgeCard({
    required this.name,
    required this.days,
    required this.regNumber,
    required this.imagePath,
  });

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) => _EnlargedStockView(
        name: name,
        days: days,
        regNumber: regNumber,
        imgPath: imagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFresh = days <= 15;
    final badgeBg = isFresh ? const Color(0xFFDFF5EA) : const Color(0xFFFBEAD1);
    final badgeText =
        isFresh ? const Color(0xFF1E8C56) : const Color(0xFFC17A15);

    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$days d',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: badgeText,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 76,
              height: 84,
              color: const Color(0xFFECEDF1),
              child: Image.network(
                getFlutterImageUrl(imagePath),
                width: 76,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.directions_car_rounded,
                  size: 30,
                  color: Color(0xFFBFC2CC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnlargedStockView extends StatelessWidget {
  final String name;
  final int days;
  final String regNumber;
  final String imgPath;

  const _EnlargedStockView({
    required this.name,
    required this.days,
    required this.regNumber,
    required this.imgPath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 260,
              width: double.infinity,
              color: const Color(0xFF1D2748),
              child: Image.network(
                getFlutterImageUrl(imgPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.directions_car_rounded,
                  size: 40,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$days days',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                regNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorStateCard extends StatelessWidget {
  final String message;
  const _ErrorStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
