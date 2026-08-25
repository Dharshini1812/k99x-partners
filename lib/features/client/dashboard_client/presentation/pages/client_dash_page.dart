// lib/features/client/dashboard_client/presentation/pages/client_dashboard_page.dart

import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/client/dashboard_client/data/model/c_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/provider.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _kDark = Color(0xFF11142A);
const _kGrey = Color(0xFF9AA0A6);
const _kAccentBlue = Color(0xFF3B4EF5);
const _kBellBg = Color(0xFFEDEFFB);

class ClientDashboardPage extends ConsumerStatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClientDashboardPageState();
}

class _ClientDashboardPageState extends ConsumerState<ClientDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(clientDashboardNotifierProvider.notifier).fetch();
      ref.read(clientStocksNotifierProvider.notifier).fetchFirstPage();
    });
  }

  /// Filters only LIVE vehicles for pre-approved loan calculations
  int _calculateLivePreApprovedLoanCount(List<ClientVehicleModel> vehicles) {
    return vehicles.where((v) {
      final isLive = (v.status ?? '').toUpperCase() == 'LIVE';
      return isLive && v.clientApproved;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(clientDashboardNotifierProvider);
    final clientStocksAsync = ref.watch(clientStocksNotifierProvider);
    final logic = ref.watch(dLogic);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              _DashboardHeader(name: logic.user?.fullName ?? ''),

              const SizedBox(height: 24),

              // ── Stat grid (Live stocks calculations only) ────────────
              statsAsync.maybeWhen(
                orElse: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                data: (statsCount) => _StatGrid(
                  stats: statsCount,
                  preApprovedLoanCount: clientStocksAsync.maybeWhen(
                    data: (vehicles, _, __) =>
                        _calculateLivePreApprovedLoanCount(vehicles),
                    orElse: () => 0,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Stock by Age ─────────────────────────────────────────
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
                      ref.read(bottomNavIndexProvider.notifier).state = 1;
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

              // ── Stock by Age Carousel (Filtered to LIVE only) ─────────
              clientStocksAsync.when(
                initial: () => const SizedBox.shrink(),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (msg) => Text(
                  msg,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                data: (vehicles, hasMore, isLoadingMore) {
                  // Filter out any non-LIVE vehicle items
                  final liveVehicles = vehicles
                      .where((v) => (v.status ?? '').toUpperCase() == 'LIVE')
                      .toList();

                  if (liveVehicles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No live stocks available',
                          style: TextStyle(color: _kGrey),
                        ),
                      ),
                    );
                  }
                  return _StockByAgeRow(vehicles: liveVehicles);
                },
              ),
            ],
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
                name.isEmpty ? 'Client' : name,
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
              width: 52,
              height: 52,
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
// STAT GRID
// ─────────────────────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  final ClientDashboardResponseModel stats;
  final int preApprovedLoanCount;

  const _StatGrid({
    required this.stats,
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
                value: stats.totalAvailableStocks,
                label: 'LIVE DEALER STOCKS',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFDFF5F0),
                iconBg: const Color(0xFFB8E7DC),
                iconColor: const Color(0xFF1E8C74),
                icon: Icons.layers_rounded,
                value: preApprovedLoanCount,
                label: 'LOAN APPROVED',
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
                value: '₹${stats.stats.totalDisbursed.toInt()}',
                label: 'APPROVED LOAN VALUE',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatTile(
                bg: const Color(0xFFEDEAFB),
                iconBg: const Color(0xFFD3CAF5),
                iconColor: const Color(0xFF6237C4),
                icon: Icons.search_rounded,
                value: stats.stats.todaysStocks,
                label: "TODAY'S LIVE STOCK",
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final Color bg;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final dynamic value;
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
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOCK BY AGE — uses List<ClientVehicleModel> (Filtered Live Only)
// ─────────────────────────────────────────────────────────────────────────────

class _StockByAgeRow extends StatelessWidget {
  final List<ClientVehicleModel> vehicles;

  const _StockByAgeRow({required this.vehicles});

  int _calculateAgeInDays(int? createdAt) {
    if (createdAt == null || createdAt == 0) return 0;
    final createdDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateTime.now().difference(createdDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final stock = vehicles[i];
          final title = [stock.makeName, stock.modelName]
              .where((e) => (e ?? '').isNotEmpty)
              .join(' ');

          return _StockByAgeCard(
            name: title.isNotEmpty ? title : stock.id,
            days: _calculateAgeInDays(stock.createdAt),
            imagePath:
                stock.dealerVehicleInspection?.frontVehicleImageUrl?.url ?? '',
            regNumber: stock.regNo ?? stock.id,
          );
        },
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
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$days days',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
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
              child: imagePath.isNotEmpty
                  ? Image.network(
                      getFlutterImageUrl(imagePath),
                      width: 76,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_car_rounded,
                        size: 30,
                        color: Color(0xFFBFC2CC),
                      ),
                    )
                  : const Icon(
                      Icons.directions_car_rounded,
                      size: 30,
                      color: Color(0xFFBFC2CC),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENLARGED VIEW
// ─────────────────────────────────────────────────────────────────────────────

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
              child: imgPath.isNotEmpty
                  ? Image.network(
                      getFlutterImageUrl(imgPath),
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.directions_car_rounded,
                          size: 48,
                          color: Color(0xFFBFC2CC),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 48,
                        color: Color(0xFFBFC2CC),
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
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                regNumber,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
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
