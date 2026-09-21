import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_filter_bar.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:dealer/features/live_auction/presentation/widgets/live_auction_voucher_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionHomePage extends ConsumerStatefulWidget {
  const AuctionHomePage({super.key});

  @override
  ConsumerState<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends ConsumerState<AuctionHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  // index -> (label, count, status sent to the API for that tab)
  static const _tabs = [
    (label: 'Auctions', count: '51', status: 'LIVE'),
    (label: 'One click buy', count: '117', status: null), // no endpoint yet
    (label: 'Upcoming', count: '12', status: 'UPCOMING'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    Future.microtask(() {
      ref.read(getStateProvider.notifier).getState();

      // Default the initial fetch to 2 months before today through
      // 2 months after today. This is seeded via setDefaultDateRange()
      // (not updateFromDate/updateToDate directly) so AuctionLogic
      // still sends fromDate/toDate to the API on launch, but the
      // filter bar's chip/badge won't treat it as something the user
      // applied until they actually open the date picker themselves.
      final today = DateTime.now();
      final twoMonthsAgo = DateTime(today.year, today.month - 2, today.day);
      final twoMonthsAhead = DateTime(today.year, today.month + 2, today.day);

      final logic = ref.read(auctionLogic);
      logic.setDefaultDateRange(twoMonthsAgo, twoMonthsAhead);

      // Intentionally NOT calling setActiveTabStatus(_tabs[0].status)
      // here — that would force status=LIVE on the very first request.
      // The initial fetch should have no status filter at all (i.e.
      // "All status"), fetching every auction in the default date
      // range; _buildAuctionsList() already filters the LIVE/UPCOMING
      // tabs locally from that broader result. activeTabStatus stays
      // null until the user actually taps a different tab, at which
      // point _onTabChanged() calls setActiveTabStatus() as before.
      logic.search();

      // In case both the states list and the user's profile are already
      // loaded (e.g. cached from a previous visit), try applying the
      // default state right away too — otherwise this happens via the
      // listeners in build() once whichever one is still loading settles.
      _tryApplyUserDefaultState();
    });
  }

  // ── Live-auctions voucher popup ─────────────────────────────────
  //
  // Shown at most once per calendar day, persisted via
  // SharedPreferences so it survives this State being recreated
  // (navigating away and back) and full app restarts — an in-memory
  // flag alone resets on both, which was the bug: the popup kept
  // reappearing on every reload instead of once a day.
  //
  // Two moments this needs to fire, and why each needs its own hook:
  //
  // 1. Cold start / fresh login — the user's very first arrival on
  //    this screen this app session. Handled by the ref.listen(
  //    liveAuctionNotifier, ...) below in build(): it fires once the
  //    launch fetch actually resolves with data, since we can't show
  //    a live-auction count before we have one.
  //
  // 2. App resumed from background — if the user was ALREADY logged
  //    in, backgrounded the app (didn't kill it), and reopens it,
  //    AuctionHomePage's initState does NOT run again (the widget
  //    never got disposed) — only didChangeAppLifecycleState() below
  //    catches this moment.
  //
  // Both paths funnel into _maybeShowVoucherPopup(), which checks
  // SharedPreferences for today's date before showing.
  static const _voucherShownKey = 'voucher_shown_this_session';

  Future<void> _maybeShowVoucherPopup() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_voucherShownKey) ?? false;
    if (alreadyShown) {
      return; // already shown since this login
    }

    if (!mounted) return;
    // Count only genuinely live (not-yet-ended) auctions — same
    // definition _isEnded() uses below, so the popup's count always
    // agrees with what the Auctions tab actually displays.
    final liveCount = ref.read(liveAuctionNotifier).whenOrNull(
          data: (auctions) => auctions.where((a) => !_isEnded(a)).length,
        );
    if (liveCount == null || liveCount <= 0) return;

    await prefs.setBool(_voucherShownKey, true);
    if (!mounted) return;

    LiveAuctionVoucherCard.maybeShow(
      context: context,
      liveCount: liveCount,
      onViewAuctions: () {
        // "Auctions" is tab index 0.
        _tabController.animateTo(0);
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Covers "already logged in, user reopens the app" — this page
      // was never remounted, so initState() won't fire again.
      _maybeShowVoucherPopup();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index].status;
    final logic = ref.read(auctionLogic);
    // AuctionLogic.search() resolves status as `explicitStatus ??
    // activeTabStatus` — explicitStatus (the Refine Results "Status"
    // filter) always wins when set. Without resetting it here, picking
    // e.g. "Live" in Refine Results and then tapping the Upcoming tab
    // would keep silently sending status=LIVE instead of UPCOMING.
    // Tapping a tab is a clearer, more recent signal of intent, so it
    // should take over cleanly.
    logic.updateStatus(AuctionLogic.statusOptions.first);
    logic.setActiveTabStatus(status);
    setState(() {});
  }

  /// Tries to default the auction list to the dealer's own state.
  /// Safe to call repeatedly — AuctionLogic.applyUserDefaultState()
  /// only ever actually applies it once (via its own internal flag)
  /// and no-ops if either the states list or the user's profile
  /// hasn't loaded yet. Called from both the states listener and the
  /// dashboard listener below, since either one can finish loading
  /// after the other — DashBoardLogic.loadUser() reads from secure
  /// storage asynchronously, so there's no guaranteed order.
  void _tryApplyUserDefaultState() {
    final states = ref.read(getStateProvider).whenOrNull(data: (s) => s);
    if (states == null) return;
    final user = ref.read(dLogic).user;
    ref.read(auctionLogic).applyUserDefaultState(user?.stateName, states);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply the dealer's own state as the default filter, once, as soon
    // as BOTH the states list and the dealer's profile are available —
    // whichever finishes loading second triggers the actual apply.
    ref.listen(getStateProvider, (previous, next) {
      next.whenOrNull(data: (_) => _tryApplyUserDefaultState());
    });
    ref.listen(dLogic, (previous, next) => _tryApplyUserDefaultState());

    // Cold-start trigger for the voucher popup: fires once the launch
    // fetch actually resolves with data (can't show a live-auction
    // count before we have one). The resume-from-background trigger
    // lives in didChangeAppLifecycleState() above.
    ref.listen(liveAuctionNotifier, (previous, next) {
      next.whenOrNull(data: (_) => _maybeShowVoucherPopup());
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: AuctionFilterBar(),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashBorderRadius: BorderRadius.circular(20),
                  labelPadding: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  tabs: [
                    for (int i = 0; i < _tabs.length; i++)
                      _buildTab(
                        label: _tabs[i].label,
                        count: _tabs[i].count,
                        isActive: _tabController.index == i,
                      ),
                  ],
                  onTap: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAuctionsList(status: 'LIVE'),
                  _buildOneClickBuyList(),
                  _buildAuctionsList(status: 'UPCOMING'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required String count,
    required bool isActive,
  }) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: isActive ? const Color(0xFF6200EE) : Colors.grey,
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF6200EE) : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// True if [vehicle] has already ended — either the backend marked it
  /// SOLD/UNSOLD, or its auction_close_dt is in the past. Used to keep
  /// closed auctions off the Auctions/Upcoming tabs regardless of
  /// whether activeTabStatus-based matching has kicked in yet (on the
  /// very first load, before any tab tap, activeTabStatus is still
  /// null — see initState — so without this check every closed auction
  /// in the date-scoped fetch would show up on the Auctions tab too).
  /// Mirrors the same close-date logic LiveAuctionCard itself uses for
  /// its "Ended" label/countdown, so the two never disagree.
  static bool _isEnded(LiveAuctionModel vehicle) {
    final statusUpper = (vehicle.status ?? '').trim().toUpperCase();
    if (statusUpper == 'SOLD' || statusUpper == 'UNSOLD') return true;

    final closeDt = vehicle.auctionCloseDt;
    if (closeDt != null && closeDt.isNotEmpty) {
      final parsed = DateTime.tryParse(closeDt.replaceFirst(' ', 'T'));
      if (parsed != null && parsed.isBefore(DateTime.now())) return true;
    }
    return false;
  }

  /// True if [vehicle] matches the free-text search query on
  /// AuctionLogic. Matches make, model, variant, registration number,
  /// vehicle id, and category/lender name — case-insensitive.
  bool _matchesSearch(LiveAuctionModel vehicle, String query) {
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

  Widget _buildAuctionsList({required String status}) {
    final state = ref.watch(liveAuctionNotifier);
    // Watch auctionLogic too — without this, typing in the search bar
    // (which only calls notifyListeners() on auctionLogic) never
    // rebuilds this list.
    final logic = ref.watch(auctionLogic);

    return state.when(
      initial: () => const LiveAuctionListSkeleton(),
      loading: () => const LiveAuctionListSkeleton(),
      error: (msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            msg,
            style: const TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (auctions) {
        // DEBUG DIAGNOSTIC — remove once the status-matching issue is
        // confirmed fixed. If auctions.isNotEmpty but the list still
        // shows "No live auctions found", check this log: it prints
        // every distinct raw `status` value actually coming back from
        // the API. The local filter below only matches an exact,
        // case-insensitive 'LIVE' / 'UPCOMING' — if the backend is
        // sending something else (e.g. 'Active', 'live ', a different
        // word entirely, or null), that's the mismatch.
        assert(() {
          final rawStatuses = auctions.map((a) => a.status).toSet().toList();
          debugPrint(
              '[AuctionHomePage] tab="$status" total fetched=${auctions.length} '
              'distinct raw status values=$rawStatuses');
          return true;
        }());

        final filtered = auctions
            // Never show already-ended auctions on the Auctions/Upcoming
            // tabs — applied unconditionally (not gated on
            // activeTabStatus being set) so the very first load, before
            // any tab tap, doesn't show SOLD/UNSOLD cards either.
            .where((a) => !_isEnded(a))
            .where((a) {
              // On the very first load, activeTabStatus is still null —
              // search() was only ever scoped by the default date range
              // (see initState: it intentionally does NOT call
              // setActiveTabStatus). At that point nothing should be
              // filtered out by status locally either beyond the
              // ended-auction guard above; just show whatever the
              // date-only fetch returned. Only once the user actually
              // taps a tab (activeTabStatus becomes non-null, and a new
              // status-scoped fetch has already happened server-side)
              // does this tab's local status match kick in, to
              // correctly split shared results between tabs on screen.
              if (logic.activeTabStatus == null) return true;
              return (a.status ?? '').trim().toUpperCase() ==
                  status.toUpperCase();
            })
            .where((a) => _matchesSearch(a, logic.searchQuery))
            .toList();

        if (filtered.isEmpty) {
          final isSearching = logic.searchQuery.trim().isNotEmpty;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : status == 'UPCOMING'
                          ? Icons.schedule_rounded
                          : Icons.directions_car_rounded,
                  size: 40,
                  color: Colors.black26,
                ),
                const SizedBox(height: 10),
                Text(
                  isSearching
                      ? 'No results for "${logic.searchQuery}"'
                      : status == 'UPCOMING'
                          ? 'No upcoming auctions'
                          : 'No live auctions found',
                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => LiveAuctionCard(vehicle: filtered[i]),
        );
      },
    );
  }

  Widget _buildOneClickBuyList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Center(
          child: Column(
            children: [
              Image.asset('images/coming_soon.jpeg'),
            ],
          ),
        ),
      ],
    );
  }
}
