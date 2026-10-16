// lib/features/live_auction/presentation/pages/events_landing_page.dart

import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/helper/feedback_helper.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/event_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/pages/auction_homepage.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventsLandingPage extends ConsumerStatefulWidget {
  const EventsLandingPage({super.key});

  @override
  ConsumerState<EventsLandingPage> createState() => _EventsLandingPageState();
}

class _EventsLandingPageState extends ConsumerState<EventsLandingPage>
    with TickerProviderStateMixin {
  late final TabController _mainTabController;
  late final TabController _subTabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedLenderId;
  String _selectedCategoryName = 'ALL';

  static const _mainTabs = [
    (label: 'Bank Auctions', mode: null),
    (label: 'Quote Price', mode: 'QUOTE'),
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _mainTabs.length, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);

    _mainTabController.addListener(_handleTabChange);
    _subTabController.addListener(_handleTabChange);

    Future.microtask(() {
      ref.read(dLogic).loadUser();
      ref.read(getLenderProvider.notifier).getLender();
      ref.read(eventProvider.notifier).fetchEvents();
      ref.read(eventUpProvider.notifier).fetchUpEvents();
    });
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mainTabController.removeListener(_handleTabChange);
    _subTabController.removeListener(_handleTabChange);
    _mainTabController.dispose();
    _subTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(int ms) {
    if (ms <= 0) return '-';
    return DateFormat('dd MMM, yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(ms));
  }

  bool _isQuoteMode(String mode) {
    final m = mode.trim().toUpperCase();
    return m == 'QUOTE' || m == '3';
  }

  String _normalizeState(String? state) {
    if (state == null) return '';
    return state.replaceAll(' ', '').trim().toLowerCase();
  }

  bool _matchesCategory(EventModel e, String selectedCategory) {
    if (selectedCategory == 'ALL') return true;
    final eventCategoryName = (e.category?.name ?? '').trim().toUpperCase();
    return eventCategoryName == selectedCategory.trim().toUpperCase();
  }

  /// Maps category names to their respective icons
  IconData _getCategoryIcon(String categoryName) {
    final normalized = categoryName.trim().toUpperCase();
    if (normalized == 'ALL') return Icons.grid_view_rounded;
    if (normalized.contains('2W') ||
        normalized.contains('BIKE') ||
        normalized.contains('TWO')) {
      return Icons.two_wheeler_rounded;
    }
    if (normalized.contains('3W') ||
        normalized.contains('THREE') ||
        normalized.contains('AUTO')) {
      return Icons.electric_rickshaw_rounded;
    }
    if (normalized.contains('4W') ||
        normalized.contains('CAR') ||
        normalized.contains('FOUR')) {
      return Icons.directions_car_filled_rounded;
    }
    if (normalized.contains('CE') ||
        normalized.contains('COMMERCIAL') ||
        normalized.contains('TRUCK') ||
        normalized.contains('EQUIPMENT')) {
      return Icons.local_shipping_rounded;
    }
    return Icons.category_rounded;
  }

  List<EventModel> _getFilteredEvents({
    required List<EventModel> events,
    required bool isForYouTab,
    required bool isQuoteTab,
  }) {
    final user = ref.watch(dLogic).user;
    final dealerState = _normalizeState(
      user?.stateName?.isNotEmpty == true ? user!.stateName : 'Tamil Nadu',
    );

    return events.where((e) {
      if (isQuoteTab && !_isQuoteMode(e.mode)) return false;

      // Filter by dynamic event category name
      if (!_matchesCategory(e, _selectedCategoryName)) return false;

      // Filter by lender if selected
      if (_selectedLenderId != null && e.lenderId != _selectedLenderId) {
        return false;
      }

      if (isForYouTab) {
        final eventState = _normalizeState(e.stateName);
        if (eventState != dealerState) return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final match = e.lenderName.toLowerCase().contains(q) ||
            e.stateName.toLowerCase().contains(q) ||
            (e.category?.name.toLowerCase().contains(q) ?? false) ||
            e.id.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  void _openAuctionHomePage(EventModel event, {required bool isUpcoming}) {
    FeedbackHelper.tap();

    final DateTime? fromDate = event.auctionStartDate > 0
        ? DateTime.fromMillisecondsSinceEpoch(event.auctionStartDate)
        : null;
    final DateTime? toDate = event.auctionEndDate > 0
        ? DateTime.fromMillisecondsSinceEpoch(event.auctionEndDate)
        : null;

    final String? resolvedMode = _isQuoteMode(event.mode) ? '3' : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuctionHomePage(
          eventId: event.id,
          initialFromDate: fromDate,
          initialToDate: toDate,
          initialMode: resolvedMode,
          lenderId: event.lenderId,
          isUpcoming: isUpcoming,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(eventProvider);
    final upcomingState = ref.watch(eventUpProvider);

    final user = ref.watch(dLogic).user;
    final dealerStateName =
        (user?.stateName != null && user!.stateName!.trim().isNotEmpty)
            ? user.stateName!.trim()
            : 'Tamil Nadu';

    final List<EventModel> liveList = liveState.maybeWhen(
      data: (res) => (res.data?.events as List<EventModel>?) ?? [],
      orElse: () => [],
    );

    final List<EventModel> upcomingList = upcomingState.maybeWhen(
      data: (res) => (res.data?.events as List<EventModel>?) ?? [],
      orElse: () => [],
    );

    final totalVehicles = liveState.maybeWhen(
      data: (res) => res.data?.totalVehiclesCount ?? 0,
      orElse: () => 0,
    );

    final auctionsCount = liveList.length;
    final quoteCount = liveList.where((e) => _isQuoteMode(e.mode)).length;

    final forYouCount = _getFilteredEvents(
      events: liveList,
      isForYouTab: true,
      isQuoteTab: false,
    ).length;

    final forAllCount = _getFilteredEvents(
      events: liveList,
      isForYouTab: false,
      isQuoteTab: false,
    ).length;

    final upCount = _getFilteredEvents(
      events: upcomingList,
      isForYouTab: false,
      isQuoteTab: false,
    ).length;

    final allEvents = [...liveList, ...upcomingList];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F9),
      endDrawer: _buildLenderDrawer(allEvents),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Section ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'LIVE EVENTS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.1,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Explore Auctions',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatTag(
                            count: '$auctionsCount',
                            label: 'Events',
                            icon: Icons.flash_on_rounded,
                            color: AppColors.primary,
                            bg: AppColors.primary.withOpacity(0.08),
                          ),
                          const SizedBox(width: 6),
                          _buildStatTag(
                            count: '$totalVehicles',
                            label: 'Vehicles',
                            icon: Icons.directions_car_rounded,
                            color: const Color(0xFF0F172A),
                            bg: const Color(0xFFF1F5F9),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Field
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
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
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              hintText:
                                  'Search lot, lender, state, category...',
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
                  const SizedBox(height: 12),

                  // Main Segmented Tab
                  Container(
                    height: 40,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _mainTabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF64748B),
                      labelStyle: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w800),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Bank Auctions',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              _badgeNumber(
                                count: '$auctionsCount',
                                isActive: _mainTabController.index == 0,
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Quote Price',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              _badgeNumber(
                                count: '$quoteCount',
                                isActive: _mainTabController.index == 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                      onTap: (_) => FeedbackHelper.tap(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Sub-tabs Row with Filter Trigger ────────────────────────
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  // Tab 1: Live Auctions
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: TabBar(
                                  controller: _subTabController,
                                  indicator: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor: const Color(0xFF64748B),
                                  labelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800),
                                  unselectedLabelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600),
                                  tabs: [
                                    Tab(text: 'For You ($forYouCount)'),
                                    Tab(text: 'For All ($forAllCount)'),
                                    Tab(text: 'Upcoming ($upCount)'),
                                  ],
                                  onTap: (_) => FeedbackHelper.tap(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Filter Drawer Button
                            Material(
                              color: (_selectedLenderId != null ||
                                      _selectedCategoryName != 'ALL')
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () =>
                                    _scaffoldKey.currentState?.openEndDrawer(),
                                child: Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: (_selectedLenderId != null ||
                                              _selectedCategoryName != 'ALL')
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    size: 18,
                                    color: (_selectedLenderId != null ||
                                            _selectedCategoryName != 'ALL')
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _subTabController,
                          children: [
                            _buildEventList(
                              state: liveState,
                              isForYou: true,
                              isQuote: false,
                              isUpcoming: false,
                              emptyMessage:
                                  'No events found in $dealerStateName',
                            ),
                            _buildEventList(
                              state: liveState,
                              isForYou: false,
                              isQuote: false,
                              isUpcoming: false,
                              emptyMessage: 'No active auction events found',
                            ),
                            _buildEventList(
                              state: upcomingState,
                              isForYou: false,
                              isQuote: false,
                              isUpcoming: true,
                              emptyMessage:
                                  'No upcoming auction events scheduled',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Quote Price
                  _buildEventList(
                    state: liveState,
                    isForYou: false,
                    isQuote: true,
                    isUpcoming: false,
                    emptyMessage: 'No quote price events available',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Category (Icon Tabs) and Lender Drawer ─────────────
  Widget _buildLenderDrawer(List<EventModel> allEvents) {
    // 1. Extract dynamic categories from the actual EventModel.category
    final Set<String> categoriesSet = {'ALL'};
    for (final e in allEvents) {
      final name = e.category?.name.trim();
      if (name != null && name.isNotEmpty) {
        categoriesSet.add(name);
      }
    }
    final List<String> availableCategories = categoriesSet.toList();

    // 2. Filter events by selected category name
    final categoryEvents = allEvents.where((e) {
      return _matchesCategory(e, _selectedCategoryName);
    }).toList();

    // 3. Aggregate lenders present in the category with their vehicle counts
    final Map<int, (String name, int count)> lenderMap = {};
    for (final event in categoryEvents) {
      final id = event.lenderId;
      final name = event.lenderName.trim();
      final count = event.totalVehiclesCount;

      if (id != null) {
        if (!lenderMap.containsKey(id)) {
          lenderMap[id] = (name, count);
        } else {
          final current = lenderMap[id]!;
          lenderMap[id] = (current.$1, current.$2 + count);
        }
      }
    }

    final totalCategoryUnits = categoryEvents.fold<int>(
      0,
      (sum, e) => sum + e.totalVehiclesCount,
    );

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Lender',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Horizontal Category Selector using Icons with Tooltips
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: availableCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = availableCategories[index];
                  final bool isSelected = _selectedCategoryName == cat;
                  final icon = _getCategoryIcon(cat);

                  return Tooltip(
                    message: cat,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryName = cat;
                          _selectedLenderId = null;
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Lender List with counts
            Expanded(
              child: lenderMap.isEmpty
                  ? Center(
                      child: Text(
                        'No lenders found for $_selectedCategoryName',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      children: [
                        RadioListTile<int?>(
                          value: null,
                          groupValue: _selectedLenderId,
                          activeColor: AppColors.primary,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'All Lenders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              _countPill(count: totalCategoryUnits),
                            ],
                          ),
                          onChanged: (val) {
                            setState(() => _selectedLenderId = null);
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Color(0xFFF1F5F9)),
                        ...lenderMap.entries.map((entry) {
                          final int lenderId = entry.key;
                          final String lenderName = entry.value.$1;
                          final int vehicleCount = entry.value.$2;

                          return RadioListTile<int?>(
                            value: lenderId,
                            groupValue: _selectedLenderId,
                            activeColor: AppColors.primary,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    lenderName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _countPill(count: vehicleCount),
                              ],
                            ),
                            onChanged: (val) {
                              setState(() => _selectedLenderId = val);
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    ),
            ),

            // Reset Button
            if (_selectedLenderId != null || _selectedCategoryName != 'ALL')
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedLenderId = null;
                        _selectedCategoryName = 'ALL';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Reset All Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _countPill({required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _badgeNumber({required String count, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.25) : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF64748B),
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStatTag({
    required String count,
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList({
    required dynamic state,
    required bool isForYou,
    required bool isQuote,
    required bool isUpcoming,
    required String emptyMessage,
  }) {
    return state.when(
      initial: () => const LiveAuctionListSkeleton(),
      loading: () => const LiveAuctionListSkeleton(),
      error: (msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg,
              style: const TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ),
      data: (response) {
        final List<EventModel> rawList =
            (response.data?.events as List<EventModel>?) ?? [];
        final filtered = _getFilteredEvents(
          events: rawList,
          isForYouTab: isForYou,
          isQuoteTab: isQuote,
        );

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_outlined,
                    size: 26,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  emptyMessage,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildModernEventCard(
              event: filtered[index],
              lotIndex: index + 1,
              isUpcoming: isUpcoming,
            );
          },
        );
      },
    );
  }

  Widget _buildModernEventCard({
    required EventModel event,
    required int lotIndex,
    required bool isUpcoming,
  }) {
    final bool isQuote = _isQuoteMode(event.mode);

    return InkWell(
      onTap: () => _openAuctionHomePage(event, isUpcoming: isUpcoming),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                border:
                    const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'ID: $lotIndex',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isQuote
                              ? const Color(0xFFFEF3C7)
                              : (isUpcoming
                                  ? const Color(0xFFEDE9FE)
                                  : const Color(0xFFDCFCE7)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isUpcoming
                              ? 'UPCOMING'
                              : (isQuote ? 'QUOTE' : 'LIVE AUCTION'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isUpcoming
                                ? const Color(0xFF6D28D9)
                                : (isQuote
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF15803D)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.lenderName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildChip(
                            icon: Icons.location_on_rounded,
                            label: event.stateName.toUpperCase(),
                            color: const Color(0xFF475569),
                            bgColor: const Color(0xFFF1F5F9),
                          ),
                          if (event.category != null)
                            _buildChip(
                              icon: _getCategoryIcon(event.category!.name),
                              label: event.category!.name,
                              color: const Color(0xFF475569),
                              bgColor: const Color(0xFFF1F5F9),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.directions_car_filled_rounded,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '${event.totalVehiclesCount} Units',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _dateBox(
                          label: 'Start Date',
                          date: _formatDate(event.auctionStartDate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateBox(
                          label: 'End Date',
                          date: _formatDate(event.auctionEndDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () =>
                          _openAuctionHomePage(event, isUpcoming: isUpcoming),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUpcoming
                            ? const Color(0xFF475569)
                            : AppColors.primary.withOpacity(0.12),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isUpcoming
                                ? 'VIEW UPCOMING'
                                : (isQuote ? 'QUOTE PRICE' : 'BID NOW'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox({required String label, required String date}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
