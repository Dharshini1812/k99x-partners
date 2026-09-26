import 'dart:async';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_card.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_filter_bar.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_skeleton.dart';
import 'package:dealer/features/live_auction/presentation/widgets/live_auction_voucher_card.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
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

  static const _tabs = [
    (label: 'Auctions', count: '51', status: 'LIVE'),
    (label: 'One click buy', count: '117', status: null),
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

      final today = DateTime.now();
      final twoMonthsAgo = DateTime(today.year, today.month - 2, today.day);
      final twoMonthsAhead = DateTime(today.year, today.month + 2, today.day);

      final logic = ref.read(auctionLogic);
      logic.setDefaultDateRange(twoMonthsAgo, twoMonthsAhead);
      logic.search();

      _tryApplyUserDefaultState();
    });
  }

  static const _voucherShownKey = 'voucher_shown_this_session';

  Future<void> _maybeShowVoucherPopup() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_voucherShownKey) ?? false;
    if (alreadyShown) return;

    if (!mounted) return;

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
        _tabController.animateTo(0);
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeShowVoucherPopup();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index].status;
    final logic = ref.read(auctionLogic);
    logic.updateStatus(AuctionLogic.statusOptions.first);
    logic.setActiveTabStatus(status);
    setState(() {});
  }

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
    ref.listen(getStateProvider, (previous, next) {
      next.whenOrNull(data: (_) => _tryApplyUserDefaultState());
    });
    ref.listen(dLogic, (previous, next) => _tryApplyUserDefaultState());
    ref.listen(liveAuctionNotifier, (previous, next) {
      next.whenOrNull(data: (_) => _maybeShowVoucherPopup());
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const _TrialStatusBanner(),
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
        final filtered = auctions
            .where((a) => !_isEnded(a))
            .where((a) {
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

class _TrialStatusBanner extends ConsumerStatefulWidget {
  const _TrialStatusBanner();

  @override
  ConsumerState<_TrialStatusBanner> createState() => _TrialStatusBannerState();
}

class _TrialStatusBannerState extends ConsumerState<_TrialStatusBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trial = ref.watch(trialLogic);
    final user = ref.watch(dLogic).user;

    // If user is already logged in or not in trial session, hide the timer
    final bool isLoggedIn = user != null;
    if (isLoggedIn || !trial.isTrialSession) {
      return const SizedBox.shrink();
    }

    final expired = trial.isTrialExpired;
    final accent = expired ? const Color(0xFFE24C4C) : const Color(0xFF3F51E8);
    final gradient = expired
        ? const [Color(0xFFFFECEC), Color(0xFFFFF7F7)]
        : const [Color(0xFFE9EDFF), Color(0xFFF4F6FF)];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: accent.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(
              expired ? Icons.timer_off_rounded : Icons.bolt_rounded,
              size: 19,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired ? 'FREE TRIAL ENDED' : 'FREE TRIAL',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                expired
                    ? Text(
                        'Sign up to unlock bidding',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: accent),
                      )
                    : _CountdownRow(remaining: trial.remaining, color: accent),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => ref.read(routeService).push(SignupRoute(), context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: accent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Text(
                'Sign up',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  final Duration remaining;
  final Color color;
  const _CountdownRow({required this.remaining, required this.color});

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _two(remaining.inHours);
    final m = _two(remaining.inMinutes.remainder(60));
    final s = _two(remaining.inSeconds.remainder(60));
    return Row(
      children: [
        _digitBox(h),
        _colon(),
        _digitBox(m),
        _colon(),
        _digitBox(s),
        const SizedBox(width: 8),
        Text('left',
            style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _digitBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
          height: 1.1,
        ),
      ),
    );
  }

  Widget _colon() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(':',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      );
}
