// lib/features/my_listings/presentation/pages/vehicle_card.dart

import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/presentation/logic/provider.dart';
import 'package:dealer/features/my_listings/presentation/widgets/pre-approved_tab.dart';
import 'package:dealer/features/my_listings/presentation/widgets/veh_media_gallery_page.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum _CardTab { pricing, details, market }

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

class CarInspectionCard extends ConsumerStatefulWidget {
  final VehicleData data;
  final VoidCallback? onRatingAdjust;
  final bool showRatingButtons;
  final bool initiallyExpanded;

  const CarInspectionCard({
    super.key,
    required this.data,
    this.onRatingAdjust,
    this.showRatingButtons = true,
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CarInspectionCardState();
}

class _CarInspectionCardState extends ConsumerState<CarInspectionCard> {
  late bool _isExpanded;
  _CardTab _activeTab = _CardTab.pricing;

  final ScrollController _tabScrollController = ScrollController();
  static const double _tabFixedContentHeight = 142.0;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant CarInspectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.id != widget.data.id) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  void _selectTab(_CardTab tab) {
    setState(() => _activeTab = tab);
    if (_tabScrollController.hasClients) {
      _tabScrollController.jumpTo(0);
    }
  }

  String _cleanStr(dynamic val) => (val?.toString() ?? '').trim().toLowerCase();

  String _buildVehicleTitle(VehicleData v) {
    final year = v.mfgYear != null && v.mfgYear! > 0 ? '${v.mfgYear}' : '';
    final make =
        ((v.makeName?.isNotEmpty == true ? v.makeName : v.make?.toString()) ??
                '')
            .toUpperCase();
    final model = ((v.modelName?.isNotEmpty == true
                ? v.modelName
                : v.model?.toString()) ??
            '')
        .toUpperCase();
    final variant = ((v.variantName?.isNotEmpty == true
                ? v.variantName
                : v.variant?.toString()) ??
            '')
        .toUpperCase();

    return [year, make, model, variant].where((s) => s.isNotEmpty).join(' ');
  }

  double _calculateAverageMarketPrice({
    required VehicleData currentVehicle,
    required List<VehicleData> vehicles,
  }) {
    final curMake = _cleanStr(currentVehicle.makeName?.isNotEmpty == true
        ? currentVehicle.makeName
        : currentVehicle.make);
    final curModel = _cleanStr(currentVehicle.modelName?.isNotEmpty == true
        ? currentVehicle.modelName
        : currentVehicle.model);
    final curVariant = _cleanStr(currentVehicle.variantName?.isNotEmpty == true
        ? currentVehicle.variantName
        : currentVehicle.variant);
    final curYear = currentVehicle.mfgYear ?? 0;

    final matchingVehicles = vehicles.where((vehicle) {
      final vMake = _cleanStr(vehicle.makeName?.isNotEmpty == true
          ? vehicle.makeName
          : vehicle.make);
      final vModel = _cleanStr(vehicle.modelName?.isNotEmpty == true
          ? vehicle.modelName
          : vehicle.model);
      final vVariant = _cleanStr(vehicle.variantName?.isNotEmpty == true
          ? vehicle.variantName
          : vehicle.variant);
      final vYear = vehicle.mfgYear ?? 0;

      final matchesMake = vMake.isNotEmpty && vMake == curMake;
      final matchesModel = vModel.isNotEmpty && vModel == curModel;
      final matchesVariant =
          curVariant.isEmpty || vVariant.isEmpty || vVariant == curVariant;
      final matchesYear = curYear == 0 || vYear == 0 || vYear == curYear;

      return matchesMake &&
          matchesModel &&
          matchesVariant &&
          matchesYear &&
          vehicle.marketPrice != null &&
          vehicle.marketPrice! > 0;
    }).toList();

    if (matchingVehicles.isEmpty) return 0;
    final total = matchingVehicles.fold<double>(
      0,
      (sum, vehicle) => sum + vehicle.marketPrice!,
    );
    return total / matchingVehicles.length;
  }

  int _calculateAgeInDays(int? createdAt) {
    if (createdAt == null || createdAt == 0) return 0;
    final createdDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateTime.now().difference(createdDate).inDays;
  }

  void _showMarketSheet(
    BuildContext context, {
    required bool isSupply,
    List<VehicleData> matches = const [],
    List<WantedMatchList>? demandMatches = const [],
    required String address,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarketDemandSheet(
        isSupply: isSupply,
        brandModel: _buildVehicleTitle(widget.data),
        matches: matches,
        demandMatches: demandMatches ?? [],
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    final liveList = ref.watch(liveStockNotifier).maybeWhen(
          data: (r) => r.data,
          orElse: () => const <VehicleData>[],
        );
    final myStockList = ref.watch(myStockNotifierProvider).maybeWhen(
          data: (r) => r.data,
          orElse: () => const <VehicleData>[],
        );

    final vehicleMap = <String, VehicleData>{};
    for (final vehicle in [...liveList, ...myStockList]) {
      if (vehicle.id != null && vehicle.id!.isNotEmpty) {
        vehicleMap[vehicle.id!] = vehicle;
      }
    }
    final allVehicles = vehicleMap.values.toList();

    bool sameVariant(VehicleData v) {
      final vMake =
          _cleanStr(v.makeName?.isNotEmpty == true ? v.makeName : v.make);
      final dataMake = _cleanStr(
          data.makeName?.isNotEmpty == true ? data.makeName : data.make);

      final vModel =
          _cleanStr(v.modelName?.isNotEmpty == true ? v.modelName : v.model);
      final dataModel = _cleanStr(
          data.modelName?.isNotEmpty == true ? data.modelName : data.model);

      final vVariant = _cleanStr(
          v.variantName?.isNotEmpty == true ? v.variantName : v.variant);
      final dataVariant = _cleanStr(data.variantName?.isNotEmpty == true
          ? data.variantName
          : data.variant);

      final vYear = v.mfgYear ?? 0;
      final dataYear = data.mfgYear ?? 0;

      if (dataMake.isEmpty || dataModel.isEmpty) return false;
      if (vMake.isEmpty || vModel.isEmpty) return false;

      final makeMatches = vMake == dataMake;
      final modelMatches = vModel == dataModel;
      final variantMatches =
          dataVariant.isEmpty || vVariant.isEmpty || vVariant == dataVariant;
      final yearMatches =
          (dataYear > 0 && vYear > 0) ? (vYear == dataYear) : true;

      return makeMatches && modelMatches && variantMatches && yearMatches;
    }

    final bool selfIsDraft = (data.status ?? '').toUpperCase() == 'DRAFT';
    bool isDraft(VehicleData v) => (v.status ?? '').toUpperCase() == 'DRAFT';

    final matchingLive = liveList
        .where((v) =>
            v.id != data.id && sameVariant(v) && (selfIsDraft || !isDraft(v)))
        .toList();
    final idsAlreadyCounted = {data.id, ...matchingLive.map((v) => v.id)};
    final matchingMyStock = myStockList
        .where((v) =>
            sameVariant(v) &&
            v.id != data.id &&
            (selfIsDraft || !isDraft(v)) &&
            !idsAlreadyCounted.contains(v.id))
        .toList();

    final similarVehicles = [...matchingLive, ...matchingMyStock];
    final similarCount = similarVehicles.length;
    final allMatchesIncludingSelf = [data, ...similarVehicles];

    final fullVehicleTitle = _buildVehicleTitle(data);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Row ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VehicleMediaGalleryPage(
                              inspection: data.dealerVehicleInspection,
                              vehicleTitle: fullVehicleTitle,
                            ),
                          ),
                        );
                      },
                      child: _Thumbnail(
                        imagePath: data.dealerVehicleInspection
                                ?.frontVehicleImageUrl?.url ??
                            '',
                        statusLabel: data.status ?? '',
                        statusColor: (data.status ?? '').toUpperCase() == 'LIVE'
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFF39C12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullVehicleTitle.isNotEmpty
                                ? fullVehicleTitle
                                : 'VEHICLE DETAILS',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${data.fuelType ?? ''} · ${data.transmission ?? ''} · ${data.bodyStyle ?? ''}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${_formatKm(data.kmDriven ?? 0)} km · ',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                if (data.dealerVehicleInspection?.ownerCount !=
                                    null) ...[
                                  TextSpan(
                                    text:
                                        '${data.dealerVehicleInspection!.ownerCount} Owner${data.dealerVehicleInspection!.ownerCount == 1 ? '' : 's'} · ',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                                TextSpan(
                                  text: data.regNo ?? '-',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AgeCalendarBadge(
                      ageInDays: _calculateAgeInDays(data.createdAt),
                    ),
                    if (widget.showRatingButtons) ...[
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          _RatingButton(
                            label: '+$similarCount',
                            isPositive: true,
                            onPressed: () {
                              widget.onRatingAdjust?.call();
                              _showMarketSheet(
                                context,
                                isSupply: true,
                                matches: allMatchesIncludingSelf,
                                address: '',
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          _RatingButton(
                            label: '-${data.wantedMatchCount ?? 0}',
                            isNegative: true,
                            onPressed: () {
                              widget.onRatingAdjust?.call();
                              _showMarketSheet(
                                context,
                                isSupply: false,
                                demandMatches: data.wantedMatchesDetails,
                                address:
                                    '${data.cityName ?? ''} · ${data.stateName ?? ''}',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Ratings & Expand ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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

              // ── Tab Content ────────────────────────────────────────────────
              if (_isExpanded) ...[
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                _TabsRow(activeTab: _activeTab, onSelect: _selectTab),
                SizedBox(
                  height: _tabFixedContentHeight,
                  child: SingleChildScrollView(
                    controller: _tabScrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: switch (_activeTab) {
                        _CardTab.pricing => _PricingTabContent(
                            key: const ValueKey('pricing'),
                            avgPrice: _calculateAverageMarketPrice(
                              currentVehicle: data,
                              vehicles: allVehicles,
                            ),
                            sellingPrice: data.dealerPrice ?? 0,
                            valuation: 'In Progress',
                            lastSoldPrice: 0,
                            avgTrend: const [],
                            sellingTrend: const [],
                            valuationTrend: const [],
                            lastSoldTrend: const [],
                          ),
                        _CardTab.details => PreApprovedTabContent(
                            key: const ValueKey('preapproved'),
                            vehicle: data,
                          ),
                        _CardTab.market => OthersTabContent(
                            key: const ValueKey('others'),
                            vehicle: data,
                          ),
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (data.status == 'DRAFT')
          Positioned(
            top: -10,
            right: -2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final logic = widget.data.toListingModel();
                  ref.read(editVehicleProvider.notifier).update(
                        (state) => (
                          model: logic,
                          refreshKey: state.refreshKey + 1,
                        ),
                      );
                  ref.read(listingProvider.notifier).update((_) => logic);
                  ref.read(bottomNavIndexProvider.notifier).state = 2;
                  ref.read(listingStepProvider.notifier).state = 0;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
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
    final hasImg = imagePath.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            color: const Color(0xFFF3F4F6),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImg
              ? Image.network(
                  getFlutterImageUrl(imagePath),
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 28,
                      color: Color(0xFFBFC2CC),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 28,
                    color: Color(0xFFBFC2CC),
                  ),
                ),
        ),
        Positioned(
          top: -4,
          left: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRatingChip extends StatelessWidget {
  final String label;
  final double rating;

  const _CategoryRatingChip({required this.label, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A6416),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF39C12)),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8A6416),
            ),
          ),
        ],
      ),
    );
  }
}

class AgeCalendarBadge extends StatelessWidget {
  final int ageInDays;
  const AgeCalendarBadge({super.key, required this.ageInDays});

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
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 36,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(height: 8, color: const Color(0xFFE74C3C)),
              Expanded(
                child: Center(
                  child: Text(
                    '$ageInDays',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final double width = isPositive ? 42 : 32;
    final double height = isPositive ? 36 : 24;
    final double fontSize = isPositive ? 15 : 11.5;

    final bg = isNegative
        ? const Color(0xFFFEF5F4)
        : isPositive
            ? const Color(0xFFF1FAF0)
            : Colors.white;

    final border = isNegative
        ? const Color(0xFFF0B0AA)
        : isPositive
            ? const Color(0xFFB3E5B3)
            : const Color(0xFFE0E0E0);

    final text = isNegative
        ? const Color(0xFFE74C3C)
        : isPositive
            ? const Color(0xFF27AE60)
            : const Color(0xFF0F0F0F);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              color: text,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandIconButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;

  const _ExpandIconButton({
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isExpanded
          ? const Color(0xFF27AE60).withOpacity(0.12)
          : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isExpanded
                  ? const Color(0xFF27AE60).withOpacity(0.35)
                  : const Color(0xFFD1D5DB),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpanded ? 'Hide' : 'More',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isExpanded
                      ? const Color(0xFF27AE60)
                      : const Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 3),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isExpanded
                      ? const Color(0xFF27AE60)
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabsRow extends StatelessWidget {
  final _CardTab activeTab;
  final ValueChanged<_CardTab> onSelect;

  const _TabsRow({required this.activeTab, required this.onSelect});

  static const _items = [
    (tab: _CardTab.pricing, label: 'Pricing'),
    (tab: _CardTab.details, label: 'Pre Approved'),
    (tab: _CardTab.market, label: 'Others'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _items.indexWhere((e) => e.tab == activeTab);

    return Container(
      color: const Color(0xFFFAFBFC),
      padding: const EdgeInsets.only(top: 8),
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
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: item.tab == activeTab
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: item.tab == activeTab
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF9AA0A6),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: tabWidth * activeIndex + tabWidth * 0.25,
                bottom: 0,
                width: tabWidth * 0.5,
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

class _PricingTabContent extends StatelessWidget {
  final double avgPrice;
  final double sellingPrice;
  final String valuation;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _PriceStatCard(
                label: 'AVG PRICE',
                value: _fmt(avgPrice),
                icon: Icons.show_chart_rounded,
                color: const Color(0xFFF5C518),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PriceStatCard(
                label: 'SELLING PRICE',
                value: _fmt(sellingPrice),
                icon: Icons.sell_outlined,
                color: const Color(0xFF27AE60),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _PriceStatCard(
                label: 'VALUATION',
                value: valuation,
                icon: Icons.insights_rounded,
                color: const Color(0xFF8E5CF7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PriceStatCard(
                label: 'LAST SOLD',
                value: _fmt(lastSoldPrice),
                icon: Icons.gavel_rounded,
                color: const Color(0xFFF39C12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PriceStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15181C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketDemandSheet extends StatefulWidget {
  final bool isSupply;
  final String brandModel;
  final List<VehicleData> matches;
  final List<WantedMatchList> demandMatches;
  final String? address;

  const _MarketDemandSheet({
    required this.isSupply,
    required this.brandModel,
    this.matches = const [],
    this.demandMatches = const [],
    required this.address,
  });

  @override
  State<_MarketDemandSheet> createState() => _MarketDemandSheetState();
}

class _MarketDemandSheetState extends State<_MarketDemandSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatusFilter = 'ALL';
  String _selectedStockAge = 'ALL';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDateFilter = false;

  static const _supplyColor = Color(0xFF27AE60);
  static const _demandColor = Color(0xFFE74C3C);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _searchCtrl.clear();
      _selectedStatusFilter = 'ALL';
      _selectedStockAge = 'ALL';
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<VehicleData> get _filteredSupplyList {
    final query = _searchCtrl.text.trim().toLowerCase();
    return widget.matches.where((v) {
      final status = (v.status ?? '').toUpperCase();
      final statusMatch = _selectedStatusFilter == 'ALL' ||
          (_selectedStatusFilter == 'LIVE' && status == 'LIVE') ||
          (_selectedStatusFilter == 'DRAFT' && status == 'DRAFT');

      final reg = (v.regNo ?? '').toLowerCase();
      final fuel = (v.fuelType ?? '').toLowerCase();
      final trans = (v.transmission ?? '').toLowerCase();
      final model = (v.modelName ?? '').toLowerCase();
      final year = '${v.mfgYear ?? ''}'.toLowerCase();

      final searchMatch = query.isEmpty ||
          reg.contains(query) ||
          fuel.contains(query) ||
          trans.contains(query) ||
          model.contains(query) ||
          year.contains(query);

      bool ageMatch = true;
      if (_selectedStockAge != 'ALL' &&
          v.createdAt != null &&
          v.createdAt! > 0) {
        final created = DateTime.fromMillisecondsSinceEpoch(v.createdAt!);
        final days = DateTime.now().difference(created).inDays;
        if (_selectedStockAge == '0-15' && days > 15) ageMatch = false;
        if (_selectedStockAge == '16-30' && (days < 16 || days > 30)) {
          ageMatch = false;
        }
        if (_selectedStockAge == '30+' && days <= 30) ageMatch = false;
      }

      bool dateMatch = true;
      if (_startDate != null &&
          _endDate != null &&
          v.createdAt != null &&
          v.createdAt! > 0) {
        final created = DateTime.fromMillisecondsSinceEpoch(v.createdAt!);
        if (created.isBefore(_startDate!) ||
            created.isAfter(_endDate!.add(const Duration(days: 1)))) {
          dateMatch = false;
        }
      }

      return statusMatch && searchMatch && ageMatch && dateMatch;
    }).toList();
  }

  List<WantedMatchList> get _filteredDemandList {
    final query = _searchCtrl.text.trim().toLowerCase();
    return widget.demandMatches.where((item) {
      final dealer = (item.dealerName ?? '').toLowerCase();
      final phone = (item.phoneNumber ?? '').toLowerCase();
      final notes = (item.notes ?? '').toLowerCase();

      final searchMatch = query.isEmpty ||
          dealer.contains(query) ||
          phone.contains(query) ||
          notes.contains(query);

      bool dateMatch = true;
      if (_startDate != null && _endDate != null && item.createdAt != null) {
        final parsedDate =
            DateTime.tryParse(item.createdAt!.replaceFirst(' ', 'T'));
        if (parsedDate != null) {
          if (parsedDate.isBefore(_startDate!) ||
              parsedDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
            dateMatch = false;
          }
        }
      }

      return searchMatch && dateMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final color = widget.isSupply ? _supplyColor : _demandColor;
    final supplyFiltered = _filteredSupplyList;
    final demandFiltered = _filteredDemandList;
    final hasActiveDate = _startDate != null || _selectedStockAge != 'ALL';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
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
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isSupply
                            ? '${widget.brandModel} (${widget.matches.length})'
                            : 'Buyer Demand (${widget.demandMatches.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEF0F2)),
                    bottom: BorderSide(color: Color(0xFFEEF0F2)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: widget.isSupply
                                    ? 'Search Reg No, Transmission, Fuel...'
                                    : 'Search Dealer Name, Phone...',
                                hintStyle: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF9AA0A6),
                                ),
                                prefixIcon:
                                    const Icon(Icons.search_rounded, size: 18),
                                suffixIcon: _searchCtrl.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () =>
                                            setState(() => _searchCtrl.clear()),
                                        child: const Icon(Icons.cancel_rounded,
                                            size: 16, color: Colors.grey),
                                      )
                                    : null,
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: Icon(
                            _showDateFilter
                                ? Icons.calendar_month
                                : Icons.calendar_today_outlined,
                            size: 18,
                            color: hasActiveDate ? color : Colors.black87,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: hasActiveDate
                                ? color.withOpacity(0.12)
                                : const Color(0xFFF3F4F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => setState(
                              () => _showDateFilter = !_showDateFilter),
                        ),
                      ],
                    ),
                    if (_showDateFilter) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.isSupply) ...[
                            Expanded(
                              child: Container(
                                height: 34,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStockAge,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'ALL', child: Text('All Age')),
                                      DropdownMenuItem(
                                          value: '0-15',
                                          child: Text('0-15 Days')),
                                      DropdownMenuItem(
                                          value: '16-30',
                                          child: Text('16-30 Days')),
                                      DropdownMenuItem(
                                          value: '30+',
                                          child: Text('30+ Days')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _selectedStockAge = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: InkWell(
                              onTap: _pickDateRange,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 34,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range_rounded,
                                        size: 13, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _startDate != null && _endDate != null
                                            ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                                            : 'Pick Date',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: _startDate != null
                                              ? Colors.black87
                                              : const Color(0xFF9AA0A6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _clearAllFilters,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 34,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.isSupply) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildFilterChip(
                            status: 'ALL',
                            label: 'All (${widget.matches.length})',
                            activeColor: color,
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            status: 'LIVE',
                            label: 'Live',
                            activeColor: _supplyColor,
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            status: 'DRAFT',
                            label: 'Pending / Draft',
                            activeColor: const Color(0xFFF39C12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: widget.isSupply
                    ? (supplyFiltered.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching stock found',
                              style: TextStyle(color: Color(0xFF9AA0A6)),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            itemCount: supplyFiltered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return CarInspectionCard(
                                data: supplyFiltered[index],
                                showRatingButtons: false,
                              );
                            },
                          ))
                    : (demandFiltered.isEmpty
                        ? const Center(
                            child: Text(
                              'No buyer demand found',
                              style: TextStyle(color: Color(0xFF9AA0A6)),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            itemCount: demandFiltered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _DemandRow(
                                address: widget.address ?? '',
                                item: demandFiltered[index],
                                color: color,
                              );
                            },
                          )),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String status,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _selectedStatusFilter == status;
    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = status),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

class _DemandRow extends ConsumerWidget {
  final WantedMatchList item;
  final Color color;
  final String address;

  const _DemandRow({
    required this.item,
    required this.color,
    required this.address,
  });

  static const _labelColor = Color(0xFF9AA0A6);
  static const _green = Color(0xFF27AE60);

  String _fmtCurrency(double v) {
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

  String _formatSubmittedAt(String raw) {
    final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed == null) return raw;
    return DateFormat('d MMM yyyy, h:mm a').format(parsed);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Strip non-digit characters except leading '+'
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNotes = item.notes != null && item.notes!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3D9D6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        item.dealerName ?? 'Dealer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((item.phoneNumber ?? '').isNotEmpty)
                  InkWell(
                    onTap: () => _makePhoneCall(item.phoneNumber!),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 13,
                            color: _labelColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.phoneNumber!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                  0xFF1E88E5), // Blue tint to indicate clickability
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (address.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: _labelColor),
                      const SizedBox(width: 4),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ],
                  ),
                if ((item.createdAt ?? '').isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: _labelColor),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted: ${_formatSubmittedAt(item.createdAt!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _labelColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3D9D6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BUDGET RANGE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: _labelColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_fmtCurrency(item.budgetFrom?.toDouble() ?? 0)} - ${_fmtCurrency(item.budgetTo?.toDouble() ?? 0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEEDED BY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: _labelColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(
                            item.neededBy ?? '-',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hasNotes)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEALER NOTES:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
