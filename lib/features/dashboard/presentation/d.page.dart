import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/core/theme/colors.dart';
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
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    Future.microtask(() {
      ref.read(dStatsProvider.notifier).getDashboardStats();
      ref
          .read(myStockNotifierProvider.notifier)
          .getMyStock(offset: 0, limit: 20);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dStatsProvider);
    final myStockAsync = ref.watch(myStockNotifierProvider);
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

              // ── Stat grid ────────────────────────────────────────────
              statsAsync.maybeWhen(
                orElse: () => const CircularProgressIndicator(),
                data: (statscount) => _StatGrid(stats: statscount),
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
              myStockAsync.maybeWhen(
                  orElse: () => const CircularProgressIndicator(),
                  data: (myStock) {
                    return _StockByAgeRow(myStock);
                  }),
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
                name,
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
// STAT GRID — 6 tiles, each with its own distinct color scheme
// ─────────────────────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // 1 — Live Stock (Indigo/Blue)
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
            // 2 — My Stock (Teal/Green)
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
        const Row(
          children: [
            // 3 — Pre-Approved Loans (Amber/Gold)
            Expanded(
              child: _StatTile(
                bg: Color(0xFFFCEFD3),
                iconBg: Color(0xFFF6D89A),
                iconColor: Color(0xFFB5750E),
                icon: Icons.verified_user_rounded,
                value: 34,
                label: 'PRE-APPROVED LOANS',
              ),
            ),
            SizedBox(width: 14),
            // 4 — Wanted Vehicles (Purple/Violet)
            Expanded(
              child: _StatTile(
                bg: Color(0xFFEDEAFB),
                iconBg: Color(0xFFD3CAF5),
                iconColor: Color(0xFF6237C4),
                icon: Icons.search_rounded,
                value: 52,
                label: 'WANTED VEHICLES',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // 5 — Total Sold Vehicles (Coral/Pink)
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
            // 6 — Total Earnings (Cyan/Sky)
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
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOCK BY AGE — compact horizontal cards: thumbnail + name/reg + age pill
// ─────────────────────────────────────────────────────────────────────────────

class _StockByAgeRow extends StatelessWidget {
  final VehicleResponse data;
  const _StockByAgeRow(this.data);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemBuilder: (_, i) {
          final stock = data.data[i];
          return _StockByAgeCard(
            name: stock.makeName ?? '',
            days: 12,
            imagePath:
                stock.dealerVehicleInspection?.frontVehicleImageUrl?.url ?? '',
            // days: stock.days,
            regNumber: stock.regNo ?? '',
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: data.data.length,
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
      child:
          // Thumbnail
          Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$days days',
              style: TextStyle(
                fontSize: 18,
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
                child: Image.network(
                  getFlutterImageUrl(imagePath),
                  width: 76,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 76,
                    height: 84,
                    color: const Color(0xFFECEDF1),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 30,
                      color: Color(0xFFBFC2CC),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENLARGED VIEW — matches RecentArrivalsCard's _EnlargedVehicleView pattern:
// transparent dialog, near-black barrier, full-size rounded photo, bottom
// black pill with reg no., age pill top-left, close (X) top-right.
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
              child: Image.network(
                getFlutterImageUrl(imgPath),
                width: 76,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 76,
                  height: 84,
                  color: const Color(0xFFECEDF1),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 30,
                    color: Color(0xFFBFC2CC),
                  ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                )),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
