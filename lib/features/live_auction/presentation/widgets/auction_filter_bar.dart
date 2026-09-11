// lib/features/auction/presentation/widgets/auction_filter_bar.dart

import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/widgets/auction_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuctionFilterBar extends ConsumerStatefulWidget {
  const AuctionFilterBar({super.key});

  @override
  ConsumerState<AuctionFilterBar> createState() => _AuctionFilterBarState();
}

class _AuctionFilterBarState extends ConsumerState<AuctionFilterBar> {
  final _searchController = TextEditingController();

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuctionFilterSheet(),
    );
  }

  /// True if the date range should be treated as a filter the user
  /// applied — i.e. it's set AND it's not just the auto-seeded launch
  /// default. See AuctionLogic.isDefaultDateRange.
  bool _dateRangeIsActiveFilter(AuctionLogic logic) {
    if (logic.isDefaultDateRange) return false;
    return logic.fromDate != null || logic.toDate != null;
  }

  int _activeFilterCount(AuctionLogic logic) {
    int count = 0;
    if (logic.selectedState != null) count++;
    if (logic.selectedCity != null) count++;
    if (logic.selectedLender != null) count++;
    if (logic.selectedCategory != AuctionLogic.categoryOptions.first) count++;
    if (logic.selectedStatus != AuctionLogic.statusOptions.first) count++;
    // Counted once for the whole range, not once per from/to — and
    // excluded entirely while it's still just the launch default.
    if (_dateRangeIsActiveFilter(logic)) count++;
    return count;
  }

  /// "Clear all" should put filters back to exactly how they were on
  /// launch (default date range + the dealer's own state), not to a
  /// blank slate — see AuctionLogic.resetToDefaults().
  void _resetFiltersToDefaults(AuctionLogic logic) {
    final states = ref.read(getStateProvider).whenOrNull(data: (s) => s) ?? [];
    final userStateName = ref.read(dLogic).user?.stateName;
    logic.resetToDefaults(userStateName: userStateName, states: states);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(auctionLogic);
    final activeCount = _activeFilterCount(logic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black45, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: logic.updateSearchQuery,
                        onSubmitted: (_) => logic.search(),
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Reg no / vehicle / bidder',
                          hintStyle:
                              TextStyle(color: Colors.black45, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          logic.updateSearchQuery('');
                        },
                        child: const Icon(Icons.cancel_rounded,
                            size: 16, color: Colors.black38),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: activeCount > 0
                  ? const Color(0xFF6200EE)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: _openFilters,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          size: 18,
                          color:
                              activeCount > 0 ? Colors.white : Colors.black87),
                      const SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              activeCount > 0 ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (activeCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$activeCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6200EE),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (activeCount > 0) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (logic.selectedState != null)
                  _chip(
                    logic.selectedState!.stateName ?? '',
                    () => logic.updateState(null),
                  ),
                if (logic.selectedCity != null)
                  _chip(
                    logic.selectedCity!.cityName ?? '',
                    () => logic.updateCity(null),
                  ),
                if (logic.selectedCategory !=
                    AuctionLogic.categoryOptions.first)
                  _chip(
                    logic.selectedCategory,
                    () => logic
                        .updateCategory(AuctionLogic.categoryOptions.first),
                  ),
                if (logic.selectedStatus != AuctionLogic.statusOptions.first)
                  _chip(
                    logic.selectedStatus,
                    () => logic.updateStatus(AuctionLogic.statusOptions.first),
                  ),
                if (_dateRangeIsActiveFilter(logic))
                  _chip(
                    'Date range',
                    () {
                      logic.updateFromDate(null);
                      logic.updateToDate(null);
                    },
                  ),
                GestureDetector(
                  onTap: () => _resetFiltersToDefaults(logic),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6200EE).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6200EE),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: Color(0xFF6200EE)),
          ),
        ],
      ),
    );
  }
}
