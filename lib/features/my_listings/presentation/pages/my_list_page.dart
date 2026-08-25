import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/presentation/logic/provider.dart';
import 'package:dealer/features/my_listings/presentation/pages/vehicle_card.dart';
import 'package:dealer/features/my_listings/presentation/pages/add_wanted_vehicle_page.dart';
import 'package:dealer/features/my_listings/presentation/widgets/vehicle_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  ConsumerState<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_TabItem> _tabs = const [
    _TabItem(label: "Live Stock"),
    _TabItem(label: "My Stock"),
    _TabItem(label: "Wanted"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    Future.microtask(
        () => ref.read(wantedListProvider.notifier).getWantedList());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "My Listings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(37),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _PeekTabBar(
              controller: _tabController,
              tabs: _tabs,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SellVehicleTab(),
          MyStockTab(), // "My Stock" — has its own Approved / My Stock sub-tabs
          AddWantedVehiclePage(),
        ],
      ),
    );
  }
}

class _TabItem {
  final String label;

  const _TabItem({required this.label});
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

// ─────────────────────────────────────────────────────────────────────────────
// DEDUP HELPER — groups vehicles by make+model+variant. Only the first of
// each group is rendered as a top-level card; the rest of that group are
// returned as "duplicates" so the representative card can fold them into
// its own +N similar-stock count instead of rendering as separate cards.
//
// Whichever item comes FIRST in the input list becomes the representative
// for its group — so callers that care about which one shows (e.g. "the
// newest of any duplicate set") need to sort the list before calling this,
// not after. See MyStockTab.build below for the sort-then-dedupe order.
// ─────────────────────────────────────────────────────────────────────────────

({List<VehicleData> display, Map<String, List<VehicleData>> groups})
    dedupeByVariant(List<VehicleData> items) {
  final Map<String, List<VehicleData>> groups = {};
  final List<VehicleData> display = [];

  for (final v in items) {
    final key = '${v.make}_${v.model}_${v.variant}';
    if (groups.containsKey(key)) {
      groups[key]!.add(v);
    } else {
      groups[key] = [v];
      display.add(v); // first occurrence becomes the representative card
    }
  }

  return (display: display, groups: groups);
}

/// Matches the Swiggy strip exactly: one continuous flat rail, each tab's
/// card has ONLY its top corners rounded (flat bottom, flush with the
/// rail — no floating pill), and the active tab rises above the shared
/// baseline while two small circles carve the concave "S" joint into its
/// base corners so it visually merges into its neighbors.
class _PeekTabBar extends StatelessWidget {
  final TabController controller;
  final List<_TabItem> tabs;

  const _PeekTabBar({
    required this.controller,
    required this.tabs,
  });

  static const double _baseHeight = 34;
  static const double _peekHeight = 0;
  static const double _notchRadius = 8;
  static const double _cardTopRadius = 15;
  static const double _railRadius = 0;

  static const Color _railBg = Color(0xFFDCEEFC);
  static const Color _activeColor = Color(0xFF4F93E3);
  static const Color _inactiveBorder = Color(0xFFB9D9F5);
  static const Color _textInactive = Color(0xFF5A87B3);
  static const Color _textActive = Colors.white;

  @override
  Widget build(BuildContext context) {
    const totalHeight = _baseHeight + _peekHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Flat rail — full width, fixed height, sits at the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: _baseHeight,
              decoration: BoxDecoration(
                color: _railBg,
                borderRadius: BorderRadius.circular(_railRadius),
              ),
            ),
          ),

          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / tabs.length;

                return AnimatedBuilder(
                  animation: controller.animation!,
                  builder: (context, _) {
                    final value = controller.animation!.value;
                    final ts = List.generate(
                      tabs.length,
                      (i) => (1 - (value - i).abs()).clamp(0.0, 1.0),
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          children: List.generate(tabs.length, (i) {
                            final t = ts[i];
                            final bg = Color.lerp(_railBg, _activeColor, t)!;
                            final textColor =
                                Color.lerp(_textInactive, _textActive, t)!;

                            // final lift = _peekHeight * t;
                            final topRadius = _lerp(16, _cardTopRadius, t);

                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => controller.animateTo(i),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: _baseHeight,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(topRadius),
                                        topRight: Radius.circular(topRadius),
                                      ),
                                      border: t < 0.3
                                          ? const Border(
                                              top: BorderSide(
                                                  color: _inactiveBorder),
                                              left: BorderSide(
                                                  color: _inactiveBorder),
                                              right: BorderSide(
                                                  color: _inactiveBorder),
                                            )
                                          : null,
                                      boxShadow: t > 0.5
                                          ? [
                                              BoxShadow(
                                                color: _activeColor
                                                    .withOpacity(0.22 * t),
                                                blurRadius: 14,
                                                offset: const Offset(0, 6),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      tabs[i].label,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: t > 0.5 ? 14 : 12.5,
                                        fontWeight: t > 0.5
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        ..._buildNotches(ts, tabWidth),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Carves the concave "S" curve at the base corners of the raised tab —
  /// this is what makes it read as merging into the rail instead of
  /// floating as a separate pill on top of it.
  List<Widget> _buildNotches(List<double> ts, double tabWidth) {
    int peakIndex = 0;
    double peakT = ts[0];
    for (int i = 1; i < ts.length; i++) {
      if (ts[i] > peakT) {
        peakT = ts[i];
        peakIndex = i;
      }
    }
    if (peakT < 0.05) return [];

    final lift = _peekHeight * peakT;
    final notchTop = _baseHeight - lift - _notchRadius;
    final leftEdge = peakIndex * tabWidth;
    final rightEdge = (peakIndex + 1) * tabWidth;

    return [
      if (peakIndex > 0)
        Positioned(
          left: leftEdge - _notchRadius,
          top: notchTop,
          child: Opacity(
            opacity: peakT,
            child: Container(
              width: _notchRadius * 2,
              height: _notchRadius * 2,
              decoration: const BoxDecoration(
                color: _railBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      if (peakIndex < tabs.length - 1)
        Positioned(
          left: rightEdge - _notchRadius,
          top: notchTop,
          child: Opacity(
            opacity: peakT,
            child: Container(
              width: _notchRadius * 2,
              height: _notchRadius * 2,
              decoration: const BoxDecoration(
                color: _railBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE STOCK TAB — fetches the full live listing set and renders each one
// through CarInspectionCard. No dedup here: Live Stock represents the
// broader market (other dealers too), so duplicates across dealers are
// real distinct listings, not accidental re-entries of the same stock.
// ─────────────────────────────────────────────────────────────────────────────

class SellVehicleTab extends ConsumerStatefulWidget {
  const SellVehicleTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SellVehicleTabState();
}

class _SellVehicleTabState extends ConsumerState<SellVehicleTab> {
  @override
  void initState() {
    Future.microtask(() => ref
        .read(liveStockNotifier.notifier)
        .getLiveStock(offset: 0, limit: 50));
    super.initState();
  }

  void _search(VehicleFilterState filters) {
    debugPrint('applyFilter → query="${filters.query}" make=${filters.make} '
        'model=${filters.model} year=${filters.year} owners=${filters.owners}');

    ref.read(liveStockNotifier.notifier).applyFilter(
          LiveStockFilter(
            query: filters.query,
            make: filters.make,
            model: filters.model,
            year: filters.year == null ? null : int.tryParse(filters.year!),
            owner: filters.owners == null
                ? null
                : int.tryParse(filters.owners!.replaceAll('+', '')),
            stockAge: filters.stockAge,
            minKm: filters.kmRange.start,
            maxKm: filters.kmRange.end,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final liveStockAsync = ref.watch(liveStockNotifier);

    return ListView(
      children: [
        VehicleFilterBar(
          // NOTE: also fire search the instant ANY pill/chip changes, not
          // just on text submit. Requires VehicleFilterBar to call this
          // from every setState that changes a filter — see patch below.
          onSearch: _search,
          onFilterChanged: _search,
          onClear: () {
            ref.read(liveStockNotifier.notifier).clearFilter();
          },
        ),
        liveStockAsync.maybeWhen(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (msg) => Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.redAccent, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    msg.isEmpty ? 'Failed to load stock' : msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(liveStockNotifier.notifier)
                        .getLiveStock(offset: 0, limit: 20),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
          data: (vehcile) {
            if (vehcile.data.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No vehicles match your filters',
                    style: TextStyle(color: Color(0xFF9AA0A6)),
                  ),
                ),
              );
            }
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(6),
              itemCount: vehcile.data.length,
              shrinkWrap: true,
              separatorBuilder: (_, __) => const SizedBox(height: 7),
              itemBuilder: (_, index) {
                return CarInspectionCard(data: vehcile.data[index]);
              },
            );
          },
        )
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY STOCK TAB — sub-tabs for "Approved" vs "Pending", both built from the
// same fetched vehicle list, split by status: live → Approved, draft →
// Pending. Both sub-tabs reuse CarInspectionCard so the list matches Live
// Stock's visual design exactly — only the filtered data differs per tab.
// ─────────────────────────────────────────────────────────────────────────────

class MyStockTab extends ConsumerStatefulWidget {
  const MyStockTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyStockTabState();
}

class _MyStockTabState extends ConsumerState<MyStockTab>
    with SingleTickerProviderStateMixin {
  late final TabController _subTabController;

  static const List<String> _subTabs = ['Pending Stock', 'Approved Stock'];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: _subTabs.length, vsync: this);
    Future.microtask(() => ref
        .read(myStockNotifierProvider.notifier)
        .getMyStock(offset: 0, limit: 10));
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  void _search(VehicleFilterState filters) {
    debugPrint('applyFilter → query="${filters.query}" make=${filters.make} '
        'model=${filters.model} year=${filters.year} owners=${filters.owners}');

    ref.read(liveStockNotifier.notifier).applyFilter(
          LiveStockFilter(
            query: filters.query,
            make: filters.make,
            model: filters.model,
            year: filters.year == null ? null : int.tryParse(filters.year!),
            owner: filters.owners == null
                ? null
                : int.tryParse(filters.owners!.replaceAll('+', '')),
            stockAge: filters.stockAge,
            minKm: filters.kmRange.start,
            maxKm: filters.kmRange.end,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final myListingAsync = ref.watch(myStockNotifierProvider);
    return Column(
      children: [
        VehicleFilterBar(
          // NOTE: also fire search the instant ANY pill/chip changes, not
          // just on text submit. Requires VehicleFilterBar to call this
          // from every setState that changes a filter — see patch below.
          onSearch: _search,
          onFilterChanged: _search,
          onClear: () {
            ref.read(liveStockNotifier.notifier).clearFilter();
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: _SubTabSwitcher(
            controller: _subTabController,
            labels: _subTabs,
          ),
        ),
        Expanded(
            child: myListingAsync.maybeWhen(
          error: (msg) => Text(msg),
          orElse: () => const Center(
              child: CircularProgressIndicator(
            color: AppColors.primary,
          )),
          data: (vehicleResponse) {
            // live → Approved Stock, draft → Pending Stock. Compared
            // case-insensitively since the exact casing the API returns
            // isn't confirmed — tighten to an exact match if needed.
            // Anything with a different status (sold, rejected, etc.)
            // won't currently show in either tab.
            //
            // Sorted newest-first by createdAt so a draft you just
            // created shows up at the top of Pending Stock instead of
            // wherever the API happened to return it. This has to
            // happen BEFORE dedupeByVariant — dedupe picks whichever
            // item comes first in the list as the group's representative
            // card, so sorting first also means the newest of any
            // duplicate-variant group is the one that actually renders.
            //
            // ADAPT: assumes VehicleData.createdAt is an int (epoch
            // millis), matching what the /review and /edit endpoints
            // returned earlier (e.g. "createdAt": 1787044957000). If
            // it's actually a String or DateTime on your model, swap the
            // comparator accordingly — e.g. for a DateTime:
            //   ..sort((a, b) => (b.createdAt ?? DateTime(0))
            //       .compareTo(a.createdAt ?? DateTime(0)))
            final approvedList = vehicleResponse.data
                .where((v) => (v.status ?? '').toLowerCase() == 'live')
                .toList()
              ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

            final pendingList = vehicleResponse.data
                .where((v) => (v.status ?? '').toLowerCase() == 'draft')
                .toList()
              ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

            return TabBarView(
              controller: _subTabController,
              children: [
                _StockList(
                    items: pendingList, expandFirstItem: false), // Pending tab
                _StockList(
                    items: approvedList,
                    expandFirstItem: true), // 👈 Approved tab expands 1st item
              ],
            );
          },
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOCK LIST — dedupes by make+model+variant before rendering so identical
// My Stock entries collapse into ONE displayed card per group. The card
// itself (via CarInspectionCard) independently computes its own +N count
// by watching both providers and excluding its own id — this list's job
// is only to decide which ONE card per group gets rendered.
// ─────────────────────────────────────────────────────────────────────────────

class _StockList extends StatelessWidget {
  final List<VehicleData> items;
  final bool expandFirstItem;
  const _StockList({
    required this.items,
    this.expandFirstItem = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No vehicles here yet',
          style: TextStyle(color: Color(0xFF9AA0A6)),
        ),
      );
    }

    final deduped = dedupeByVariant(items);

    return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount:
            deduped.display.length, // ✅ matches deduped list, not items.length
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final vehicleData = deduped.display[index];
          // No myStockDuplicates plumbing needed here anymore — the card
          // itself watches myStockNotifierProvider and self-excludes by
          // id, so it computes the same +N total regardless of which
          // tab/list it's rendered from. dedupeByVariant is only used
          // here to decide which ONE card to render per group.
          return CarInspectionCard(
            data: vehicleData,
            initiallyExpanded: expandFirstItem && index == 0,
          );
        });
  }
}

/// A compact dark segmented pill for switching between sub-tabs — same
/// neutral charcoal-on-light-rail style as the app's other segmented
/// controls, sized down so it reads as a secondary control beneath the
/// main Peek tab bar rather than competing with it.
class _SubTabSwitcher extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const _SubTabSwitcher({
    required this.controller,
    required this.labels,
  });

  static const Color _railColor = Color(0xFFF3F4F6);
  static const Color _inactiveColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _railColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segWidth = constraints.maxWidth / labels.length;

          return AnimatedBuilder(
            animation: controller.animation!,
            builder: (context, _) {
              final value =
                  controller.animation!.value.clamp(0, labels.length - 1);

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    left: segWidth * value,
                    width: segWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(labels.length, (i) {
                      return SizedBox(
                        width: segWidth,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.animateTo(i),
                          child: AnimatedBuilder(
                            animation: controller.animation!,
                            builder: (context, _) {
                              final v = controller.animation!.value;
                              final t = (1 - (v - i).abs()).clamp(0.0, 1.0);
                              return Center(
                                child: Text(
                                  labels[i],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: t > 0.5
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: Color.lerp(
                                      _inactiveColor,
                                      Colors.white,
                                      t,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class WantedVehicleTab extends StatelessWidget {
  const WantedVehicleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              "Wanted Vehicle ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("Vehicle details"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
