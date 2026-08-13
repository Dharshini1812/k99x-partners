import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/presentation/widgets/pre-approved_tab.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _CardTab { pricing, details, market }

// ─────────────────────────────────────────────────────────────────────────────
// STOCK STATUS — drives the corner badge (LIVE / APPROVED / PENDING) and its
// color, so the same card can represent Live Stock, Approved Stock, or
// Pending Stock just by passing a different status in.
// ─────────────────────────────────────────────────────────────────────────────

enum StockStatus { live, approved, pending }

extension StockStatusX on StockStatus {
  String get label => switch (this) {
        StockStatus.live => 'LIVE',
        StockStatus.approved => 'APPROVED',
        StockStatus.pending => 'PENDING',
      };

  Color get color => switch (this) {
        StockStatus.live => const Color(0xFF27AE60),
        StockStatus.approved => const Color(0xFF2E86DE),
        StockStatus.pending => const Color(0xFFF39C12),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// CAR LISTING DATA — everything CarInspectionCard needs to render one card.
// Build this from your `Car` model (see CarListingData.fromCar below) so
// Live / Approved / Pending stock all reuse the same widget with their own
// real data instead of the old hardcoded demo values.
// ─────────────────────────────────────────────────────────────────────────────

class CarListingData {
  final String title;
  final String specs; // e.g. "Petrol · Manual · SUV"
  final int km;
  final int owners;
  final String plate;
  final int ageInDays;
  final StockStatus status;
  final String imagePath;

  final double exteriorRating;
  final double interiorRating;
  final double engineRating;

  final double avgPrice;
  final double sellingPrice;
  final double valuation;
  final double lastSoldPrice;
  final List<double> avgTrend;
  final List<double> sellingTrend;
  final List<double> valuationTrend;
  final List<double> lastSoldTrend;

  final String stockId;
  final String registration;
  final String location;
  final String type;
  final String listedDate;

  const CarListingData({
    required this.title,
    required this.specs,
    required this.km,
    required this.owners,
    required this.plate,
    required this.ageInDays,
    required this.status,
    this.imagePath = 'images/img2.webp',
    this.exteriorRating = 5,
    this.interiorRating = 5,
    this.engineRating = 5,
    required this.avgPrice,
    required this.sellingPrice,
    required this.valuation,
    required this.lastSoldPrice,
    required this.avgTrend,
    required this.sellingTrend,
    required this.valuationTrend,
    required this.lastSoldTrend,
    required this.stockId,
    required this.registration,
    required this.location,
    required this.type,
    required this.listedDate,
  });
}

class CarInspectionCard extends ConsumerStatefulWidget {
  final VehicleData data;
  final VoidCallback? onRatingAdjust;
  const CarInspectionCard({
    super.key,
    required this.data,
    this.onRatingAdjust,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CarInspectionCardState();
}

class _CarInspectionCardState extends ConsumerState<CarInspectionCard> {
  bool _isExpanded = false;
  _CardTab _activeTab = _CardTab.pricing;
  static const double _tabContentHeight = 200;

  final ScrollController _tabScrollController = ScrollController();

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _selectTab(_CardTab tab) {
    setState(() => _activeTab = tab);

    if (_tabScrollController.hasClients) {
      _tabScrollController.jumpTo(0);
    }
  }

  void _showMarketSheet(BuildContext context, {required bool isSupply}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarketDemandSheet(
        isSupply: isSupply,
        brandModel: widget.data.makeName ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Summary Row: Thumbnail + Info + Rating buttons ────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumbnail(
                      imagePath: data.dealerVehicleInspection
                              ?.frontVehicleImageUrl?.url ??
                          '',
                      statusLabel: data.status ?? '',
                      statusColor:
                          data.status == 'LIVE' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.makeName ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${data.fuelType}.${data.transmission}.${data.bodyStyle}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${_formatKm(data.kmDriven ?? 0)} km · ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: data.dealerVehicleInspection
                                              ?.ownerCount ==
                                          null
                                      ? ''
                                      : '${data.dealerVehicleInspection?.ownerCount}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (data.dealerVehicleInspection?.ownerCount !=
                                    null)
                                  TextSpan(
                                    text: data.dealerVehicleInspection
                                                ?.ownerCount ==
                                            1
                                        ? ' Owner'
                                        : ' Owners',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                if (data.dealerVehicleInspection?.ownerCount !=
                                    null)
                                  const TextSpan(
                                    text: ' · ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                TextSpan(
                                  text: data.regNo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _AgeCalendarBadge(ageInDays: 13),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        _RatingButton(
                          label: '+${data.similarPlatformCount}',
                          isPositive: true,
                          onPressed: () {
                            widget.onRatingAdjust?.call();
                            _showMarketSheet(context, isSupply: true);
                          },
                        ),
                        const SizedBox(height: 6),
                        _RatingButton(
                          label: '-${data.wantedMatchCount}',
                          isNegative: true,
                          onPressed: () {
                            widget.onRatingAdjust?.call();
                            _showMarketSheet(context, isSupply: false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Category Ratings + Expand Icon (same row) ──────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryRatingChip(
                        label: 'Exterior',
                        rating: double.tryParse(data.dealerVehicleInspection
                                    ?.exteriorCondition ??
                                '') ??
                            0.0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _CategoryRatingChip(
                        label: 'Interior',
                        rating: double.tryParse(data.dealerVehicleInspection
                                    ?.interiorCondition ??
                                '') ??
                            0.0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _CategoryRatingChip(
                        label: 'Engine',
                        rating: double.tryParse(
                                data.dealerVehicleInspection?.engineCondition ??
                                    '') ??
                            0.0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    _ExpandIconButton(
                      isExpanded: _isExpanded,
                      onPressed: _toggleExpanded,
                    ),
                  ],
                ),
              ),

              // ── Tabs + Content (only when expanded) ──────────────────────
              if (_isExpanded) ...[
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                _TabsRow(
                  activeTab: _activeTab,
                  onSelect: _selectTab,
                ),
                // Fixed-height, scrollable content area — every tab renders
                // inside the same box, so switching tabs never resizes the
                // card. If a tab's content is taller than _tabContentHeight,
                // it scrolls, and the scrollbar stays visible so that's clear.
                SizedBox(
                  height: _tabContentHeight,
                  child: Scrollbar(
                    controller: _tabScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _tabScrollController,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: switch (_activeTab) {
                          _CardTab.pricing => _PricingTabContent(
                              key: const ValueKey('pricing'),
                              avgPrice: data.dealerPrice ?? 0,
                              sellingPrice: data.marketPrice ?? 0,
                              valuation: data.marketPrice ?? 0,
                              lastSoldPrice: data.marketPrice ?? 0,
                              avgTrend: const [],
                              sellingTrend: const [],
                              valuationTrend: const [],
                              lastSoldTrend: const [],
                            ),
                          // NOTE: PreApprovedTabContent / OthersTabContent live in
                          // pre-approved_tab.dart, which wasn't part of what you
                          // shared — they still render static content for now.
                          // If you want them per-card too, give them the same
                          // treatment: accept a data param instead of hardcoding.
                          _CardTab.details => PreApprovedTabContent(
                              key: const ValueKey('preapproved'),
                              vehicle: data),
                          _CardTab.market => OthersTabContent(
                              key: const ValueKey('others'), vehicle: data),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ✅ AFTER
        if (data.status == 'DRAFT')
          Positioned(
            top: -10,
            right: -2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final logic = widget.data.toListingModel();

                  // ─────────────────────────────────────────────────────────────
                  // ✅ UPDATE: FORCE THE CHANGE
                  // ─────────────────────────────────────────────────────────────

                  // 1. Get current refreshKey

                  // 2. We explicitly use StateNotifier syntax here to ensure
                  // the incremented counter forces the update.
                  ref.read(editVehicleProvider.notifier).update((state) => (
                        model: logic,
                        refreshKey: state.refreshKey + 1, // FORCE CHANGE HERE
                      ));

                  // 3. Keep updating the main listing provider...
                  ref.read(listingProvider.notifier).state = logic;

                  // 4. Switch to tab...
                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                  ref.read(listingStepProvider.notifier).state = 0;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_outlined, // or Icons.edit_calendar
                    size: 16,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatKm(int km) {
    final s = km.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0 && posFromRight % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THUMBNAIL WITH STATUS TAG (LIVE / APPROVED / PENDING)
// ─────────────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String imagePath;
  final String statusLabel;
  final Color statusColor;

  const _Thumbnail({
    required this.imagePath,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.directions_car_rounded,
              size: 32,
              color: Color(0xFFCCCCCC),
            ),
          ),
        ),
        Positioned(
          top: -6,
          left: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY RATING CHIP (Exterior / Interior / Engine)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryRatingChip extends StatelessWidget {
  final String label;
  final double rating;

  const _CategoryRatingChip({
    required this.label,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A6416),
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              size: 13,
              color: Color(0xFFF39C12),
            ),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A6416),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AGE CALENDAR BADGE — calendar-shaped icon with the day count inside it
// ─────────────────────────────────────────────────────────────────────────────

class _AgeCalendarBadge extends StatelessWidget {
  final int ageInDays;

  const _AgeCalendarBadge({required this.ageInDays});

  static const Color _stripColor = Color(0xFFE74C3C);
  static const Color _numberColor = Color(0xFF1A1A1A);
  static const Color _ringColor = Color(0xFFB0B5C0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'AGE',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9AA0A6),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Two small binder-ring tabs poking up from the top edge.
            Positioned(
              top: -3,
              left: 7,
              child: Container(
                width: 3,
                height: 6,
                decoration: BoxDecoration(
                  color: _ringColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              top: -3,
              right: 7,
              child: Container(
                width: 3,
                height: 6,
                decoration: BoxDecoration(
                  color: _ringColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // The calendar body itself.
            Container(
              width: 34,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(height: 8, color: _stripColor),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$ageInDays',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _numberColor,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'days',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9AA0A6),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RATING BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _RatingButton extends StatelessWidget {
  final String label;
  final bool isNegative;
  final bool isPositive;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    this.isNegative = false,
    this.isPositive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: isNegative ? 27 : 40,
          height: isNegative ? 27 : 40,
          decoration: BoxDecoration(
            color: isNegative
                ? const Color(0xFFFEF5F4)
                : isPositive
                    ? const Color(0xFFF1FAF0)
                    : Colors.white,
            border: Border.all(
              color: isNegative
                  ? const Color(0xFFF0B0AA)
                  : isPositive
                      ? const Color(0xFFB3E5B3)
                      : const Color(0xFFE0E0E0),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isNegative ? 14 : 21,
                color: isNegative
                    ? const Color(0xFFE74C3C)
                    : isPositive
                        ? const Color(0xFF27AE60)
                        : const Color(0xFF0F0F0F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPAND ICON BUTTON (sits in the ratings row, far right)
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandIconButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;

  const _ExpandIconButton({
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.black,
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABS ROW — icon-on-top pill style with a sliding indicator (Price Intel style)
// ─────────────────────────────────────────────────────────────────────────────

class _TabsRow extends StatelessWidget {
  final _CardTab activeTab;
  final ValueChanged<_CardTab> onSelect;

  const _TabsRow({
    required this.activeTab,
    required this.onSelect,
  });

  static const _items = [
    (tab: _CardTab.pricing, label: 'Pricing'),
    (
      tab: _CardTab.details,
      label: 'Pre Approved',
    ),
    (tab: _CardTab.market, label: 'Others'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _items.indexWhere((e) => e.tab == activeTab);

    return Container(
      color: const Color(0xFFFAFBFC),
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _items.length;
          return Stack(
            children: [
              Row(
                children: [
                  for (final item in _items)
                    Expanded(
                      child: InkWell(
                        onTap: () => onSelect(item.tab),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: item.tab == activeTab
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: item.tab == activeTab
                                      ? const Color(0xFF1A1A1A)
                                      : const Color(0xFF9AA0A6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: tabWidth * activeIndex + tabWidth * 0.28,
                bottom: 0,
                width: tabWidth * 0.44,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRICING TAB — Avg / Selling / Last Sold cards with sparkline trend graphs
// ─────────────────────────────────────────────────────────────────────────────

class _PricingTabContent extends StatelessWidget {
  final double avgPrice;
  final double sellingPrice;
  final double valuation;
  final double lastSoldPrice;
  final List<double> avgTrend;
  final List<double> sellingTrend;
  final List<double> valuationTrend;
  final List<double> lastSoldTrend;

  const _PricingTabContent({
    super.key,
    required this.avgPrice,
    required this.sellingPrice,
    required this.valuation,
    required this.lastSoldPrice,
    required this.avgTrend,
    required this.sellingTrend,
    required this.valuationTrend,
    required this.lastSoldTrend,
  });

  static const _green = Color(0xFF27AE60);
  static const _red = Color(0xFFE74C3C);
  static const _amber = Color(0xFFF39C12); // Last Sold — fixed
  static const _yellow = Color(0xFFF5C518); // Avg Price — fixed, never changes
  static const _valuationColor = Color(0xFF8E5CF7); // fixed

  String _fmt(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0) {
        if (posFromRight == 3 ||
            (posFromRight > 3 && (posFromRight - 3) % 2 == 0)) {
          buf.write(',');
        }
      }
      buf.write(s[i]);
    }
    return '₹$buf';
  }

  @override
  Widget build(BuildContext context) {
    // Only Selling Price reacts to the comparison:
    // selling below avg market price → red (underpriced/loss).
    // selling at or above avg market price → green.
    final bool isBelowMarket = avgPrice > sellingPrice;
    final Color sellingColor = isBelowMarket ? _red : _green;
    final IconData sellingIcon =
        isBelowMarket ? Icons.trending_down_rounded : Icons.trending_up_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PriceStatCard(
                  fullWidth: false,
                  label: 'AVG PRICE',
                  subtitle: 'Market Average',
                  value: _fmt(avgPrice),
                  icon: Icons.show_chart_rounded,
                  color: _yellow, // fixed — never flips red/green
                  trend: avgTrend,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PriceStatCard(
                  fullWidth: false,
                  label: 'SELLING PRICE',
                  subtitle: 'Listed Price',
                  value: _fmt(sellingPrice),
                  icon: sellingIcon,
                  color: sellingColor, // reacts to avg vs selling
                  trend: sellingTrend,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PriceStatCard(
                  fullWidth: false,
                  label: 'VALUATION',
                  subtitle: 'Estimated Value',
                  value: _fmt(valuation),
                  icon: Icons.insights_rounded,
                  color: _valuationColor,
                  trend: valuationTrend,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PriceStatCard(
                  fullWidth: false,
                  label: 'LAST SOLD',
                  subtitle: 'Last Sold Price',
                  value: _fmt(lastSoldPrice),
                  icon: Icons.gavel_rounded,
                  color: _amber,
                  trend: lastSoldTrend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceStatCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final List<double> trend;
  final bool fullWidth;

  const _PriceStatCard({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.fullWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15181C),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARKET / DEMAND BOTTOM SHEET
// Supply mode (+5) → cars of this brand/model currently live in the market.
// Demand mode (−1) → buyers currently looking for this brand/model.
// ─────────────────────────────────────────────────────────────────────────────

class _MarketDemandSheet extends StatelessWidget {
  final bool isSupply;
  final String brandModel;

  const _MarketDemandSheet({
    required this.isSupply,
    required this.brandModel,
  });

  static const _supplyColor = Color(0xFF27AE60);
  static const _demandColor = Color(0xFFE74C3C);

  // Demo data — replace with a real query filtered by brand/model.
  static const List<_SupplyItem> _supplyItems = [
    _SupplyItem(
        variant: 'Alto LXI',
        specs: 'Petrol · Manual · SUV',
        price: '₹5,68,767',
        valuation: '₹3,79,722',
        location: 'T.Nagar, Chennai',
        postedDaysAgo: 1),
    _SupplyItem(
        variant: 'Alto VXI',
        specs: 'Petrol · Manual · SUV',
        price: '₹6,10,000',
        valuation: '₹4,05,000',
        location: 'Anna Nagar, Chennai',
        postedDaysAgo: 2),
    _SupplyItem(
        variant: 'Alto LXI',
        specs: 'Petrol · Manual · SUV',
        price: '₹5,45,000',
        valuation: '₹3,70,000',
        location: 'Velachery, Chennai',
        postedDaysAgo: 3),
    _SupplyItem(
        variant: 'Alto K10',
        specs: 'Petrol · Manual · Hatchback',
        price: '₹5,90,000',
        valuation: '₹3,95,000',
        location: 'Adyar, Chennai',
        postedDaysAgo: 4),
    _SupplyItem(
        variant: 'Alto LXI',
        specs: 'Petrol · Manual · SUV',
        price: '₹5,60,000',
        valuation: '₹3,75,000',
        location: 'Tambaram, Chennai',
        postedDaysAgo: 6),
  ];

  static const List<_DemandItem> _demandItems = [
    _DemandItem(area: 'T.Nagar', budget: '₹5.5L – ₹6L', urgency: 'High'),
    _DemandItem(area: 'Porur', budget: '₹5L – ₹5.8L', urgency: 'Medium'),
    _DemandItem(area: 'Velachery', budget: '₹5.8L – ₹6.2L', urgency: 'High'),
    _DemandItem(area: 'Anna Nagar', budget: '₹5.2L – ₹5.6L', urgency: 'Low'),
  ];

  @override
  Widget build(BuildContext context) {
    final color = isSupply ? _supplyColor : _demandColor;
    final count = isSupply ? _supplyItems.length : _demandItems.length;
    final title = isSupply ? 'Available in Market' : 'Buyer Demand';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSupply
                            ? Icons.storefront_rounded
                            : Icons.groups_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            brandModel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSupply ? '$count Live' : '$count Wanted',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF888888),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount:
                      isSupply ? _supplyItems.length : _demandItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return isSupply
                        ? _SupplyRow(item: _supplyItems[index])
                        : _DemandRow(item: _demandItems[index], color: color);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPLY ROW (+5 sheet — live listings of this brand/model)
// ─────────────────────────────────────────────────────────────────────────────

class _SupplyItem {
  final String variant;
  final String specs;
  final String price;
  final String valuation;
  final String location;
  final int postedDaysAgo;

  const _SupplyItem({
    required this.variant,
    required this.specs,
    required this.price,
    required this.valuation,
    required this.location,
    required this.postedDaysAgo,
  });
}

/// Mirrors CarInspectionCard's header (thumbnail + LIVE badge, title, specs,
/// Selling Price / Valuation pairing) inside the same card shell — same
/// visual identity, but read-only. No nested rating buttons here, since
/// tapping +5/−1 on a card *inside* the +5/−1 sheet would open another
/// sheet on top of this one, which gets confusing fast.
class _SupplyRow extends StatelessWidget {
  final _SupplyItem item;

  const _SupplyRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniThumbnail(imagePath: 'images/img2.webp'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.variant,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.specs,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF666666),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.location} · ${item.postedDaysAgo == 1 ? "1 day ago" : "${item.postedDaysAgo} days ago"}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9AA0A6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.price,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.valuation,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF39C12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Smaller version of CarInspectionCard's _Thumbnail — same LIVE badge
/// treatment, scaled down to fit a list row instead of the card header.
class _MiniThumbnail extends StatelessWidget {
  final String imagePath;

  const _MiniThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.directions_car_rounded,
              size: 22,
              color: Color(0xFFCCCCCC),
            ),
          ),
        ),
        Positioned(
          top: -5,
          left: -5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMAND ROW (−1 sheet — buyers looking for this brand/model)
// ─────────────────────────────────────────────────────────────────────────────

class _DemandItem {
  final String area;
  final String budget;
  final String urgency; // High / Medium / Low

  const _DemandItem({
    required this.area,
    required this.budget,
    required this.urgency,
  });
}

class _DemandRow extends StatelessWidget {
  final _DemandItem item;
  final Color color;

  const _DemandRow({required this.item, required this.color});

  Color get _urgencyColor {
    switch (item.urgency) {
      case 'High':
        return const Color(0xFFE74C3C);
      case 'Medium':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF27AE60);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Looking near ${item.area}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Budget: ${item.budget}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _urgencyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.urgency,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _urgencyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
