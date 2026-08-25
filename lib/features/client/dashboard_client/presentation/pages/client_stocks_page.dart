// lib/features/client/presentation/pages/client_stocks_page.dart

import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/provider.dart';
import 'package:dealer/features/client/dashboard_client/presentation/widgets/client_stock_card.dart';
import 'package:dealer/features/client/dashboard_client/presentation/widgets/loan_approval_sheet.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ClientStocksPage extends ConsumerStatefulWidget {
  const ClientStocksPage({super.key});

  @override
  ConsumerState<ClientStocksPage> createState() => _ClientStocksPageState();
}

class _ClientStocksPageState extends ConsumerState<ClientStocksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStockAge = 'ALL';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(clientStocksNotifierProvider.notifier).fetchFirstPage());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Live Stocks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _StockStatusList(
              status: 'LIVE',
              searchQuery: _searchController.text,
              stockAge: _selectedStockAge,
              startDate: _startDate,
              endDate: _endDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasActiveFilter = _searchController.text.isNotEmpty ||
        _selectedStockAge != 'ALL' ||
        _startDate != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
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
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search make, model, variant...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF9CA3AF),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () =>
                                  setState(() => _searchController.clear()),
                              child: const Icon(Icons.cancel_rounded,
                                  size: 16, color: Colors.grey),
                            )
                          : null,
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: Icon(
                  _isFilterExpanded
                      ? Icons.filter_list_off_rounded
                      : Icons.tune_rounded,
                  size: 18,
                  color: hasActiveFilter ? AppColors.primary : Colors.black87,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: hasActiveFilter
                      ? AppColors.primary.withOpacity(0.12)
                      : const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () =>
                    setState(() => _isFilterExpanded = !_isFilterExpanded),
              ),
            ],
          ),
          if (_isFilterExpanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStockAge,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'ALL', child: Text('All Stocks')),
                          DropdownMenuItem(
                              value: '0-15', child: Text('0-15 Days')),
                          DropdownMenuItem(
                              value: '16-30', child: Text('16-30 Days')),
                          DropdownMenuItem(
                              value: '30+', child: Text('30+ Days')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedStockAge = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                                  : 'Date Range',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
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
                const SizedBox(width: 8),
                InkWell(
                  onTap: _clearFilters,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 11.5,
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
        ],
      ),
    );
  }
}

class _StockStatusList extends ConsumerWidget {
  final String status;
  final String searchQuery;
  final String stockAge;
  final DateTime? startDate;
  final DateTime? endDate;

  const _StockStatusList({
    required this.status,
    required this.searchQuery,
    required this.stockAge,
    this.startDate,
    this.endDate,
  });

  String _getKey(ClientVehicleModel v) {
    return '${v.makeName}_${v.modelName}_${v.variantName}'.toLowerCase().trim();
  }

  Map<String, List<ClientVehicleModel>> _groupAllVehicles(
      List<ClientVehicleModel> allVehicles) {
    final Map<String, List<ClientVehicleModel>> map = {};
    for (final v in allVehicles) {
      final key = _getKey(v);
      map.putIfAbsent(key, () => []).add(v);
    }
    return map;
  }

  List<ClientVehicleModel> _applyFilters(List<ClientVehicleModel> vehicles) {
    return vehicles.where((v) {
      if ((v.status ?? '').toUpperCase() != status) return false;

      final q = searchQuery.toLowerCase().trim();
      if (q.isNotEmpty) {
        final title =
            '${v.makeName} ${v.modelName} ${v.variantName}'.toLowerCase();
        final reg = (v.regNo ?? '').toLowerCase();
        final id = v.id.toLowerCase();
        if (!title.contains(q) && !reg.contains(q) && !id.contains(q)) {
          return false;
        }
      }

      if (stockAge != 'ALL' && v.createdAt != null) {
        final created = DateTime.fromMillisecondsSinceEpoch(v.createdAt!);
        final days = DateTime.now().difference(created).inDays;
        if (stockAge == '0-15' && days > 15) return false;
        if (stockAge == '16-30' && (days < 16 || days > 30)) return false;
        if (stockAge == '30+' && days <= 30) return false;
      }

      if (startDate != null && endDate != null && v.createdAt != null) {
        final created = DateTime.fromMillisecondsSinceEpoch(v.createdAt!);
        if (created.isBefore(startDate!) ||
            created.isAfter(endDate!.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<ClientVehicleModel> _getDistinctPrimaryVehicles(
      List<ClientVehicleModel> vehicles) {
    final Map<String, ClientVehicleModel> distinct = {};
    for (final v in vehicles) {
      final key = _getKey(v);
      if (!distinct.containsKey(key)) {
        distinct[key] = v;
      }
    }
    return distinct.values.toList();
  }

  void _showMatchingStocksModal(
    BuildContext context, {
    required List<ClientVehicleModel> matchingVehicles,
    required WidgetRef ref,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MatchingStocksModalSheet(
        matchingVehicles: matchingVehicles,
        onRefresh: () =>
            ref.read(clientStocksNotifierProvider.notifier).fetchFirstPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientStocksNotifierProvider);

    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 32),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref
                  .read(clientStocksNotifierProvider.notifier)
                  .fetchFirstPage(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (allVehicles, hasMore, isLoadingMore) {
        final allGroupedMap = _groupAllVehicles(allVehicles);
        final filteredVehicles = _applyFilters(allVehicles);
        final distinctList = _getDistinctPrimaryVehicles(filteredVehicles);

        if (distinctList.isEmpty) {
          return const Center(
            child: Text(
              'No matching live stocks found',
              style: TextStyle(color: Color(0xFF9AA0A6)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(clientStocksNotifierProvider.notifier).fetchFirstPage(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 300) {
                ref.read(clientStocksNotifierProvider.notifier).loadNextPage();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: distinctList.length + (isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= distinctList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final vehicle = distinctList[index];
                final key = _getKey(vehicle);
                final allMatching = allGroupedMap[key] ?? [vehicle];
                final additionalCount = allMatching.length - 1;

                return ClientStockCard(
                  vehicle: vehicle,
                  badgeCount: additionalCount,
                  onBadgeTap: () => _showMatchingStocksModal(
                    context,
                    matchingVehicles: allMatching,
                    ref: ref,
                  ),
                  onPreApproval: () async {
                    final approved = await showLoanApprovalSheet(
                      context,
                      vehicle: vehicle,
                    );
                    if (approved == true) {
                      ref
                          .read(clientStocksNotifierProvider.notifier)
                          .fetchFirstPage();
                    }
                  },
                  onViewReport: () {},
                  onDigitalInspection: () {},
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _MatchingStocksModalSheet extends StatefulWidget {
  final List<ClientVehicleModel> matchingVehicles;
  final VoidCallback onRefresh;

  const _MatchingStocksModalSheet({
    required this.matchingVehicles,
    required this.onRefresh,
  });

  @override
  State<_MatchingStocksModalSheet> createState() =>
      _MatchingStocksModalSheetState();
}

class _MatchingStocksModalSheetState extends State<_MatchingStocksModalSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ClientVehicleModel> get _filteredList {
    final query = _searchCtrl.text.trim().toLowerCase();
    return widget.matchingVehicles.where((item) {
      final reg = (item.regNo ?? '').toLowerCase();
      final id = item.id.toLowerCase();
      final dealer = (item.dealerFirstName ?? '').toLowerCase();
      final city = (item.cityName ?? '').toLowerCase();

      final searchMatch = query.isEmpty ||
          reg.contains(query) ||
          id.contains(query) ||
          dealer.contains(query) ||
          city.contains(query);

      return searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.matchingVehicles.first;
    final title = '${first.makeName ?? ''} ${first.modelName ?? ''}'.trim();
    final filtered = _filteredList;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
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
                      '$title Stocks (${widget.matchingVehicles.length})',
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(
                  top: BorderSide(color: Color(0xFFEEF0F2)),
                  bottom: BorderSide(color: Color(0xFFEEF0F2)),
                ),
              ),
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search Reg No, Dealer, City...',
                    hintStyle: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF9AA0A6)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() => _searchCtrl.clear()),
                            child: const Icon(Icons.cancel_rounded,
                                size: 16, color: Colors.grey),
                          )
                        : null,
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching vehicles found',
                        style:
                            TextStyle(color: Color(0xFF9AA0A6), fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (itemCtx, index) {
                        final item = filtered[index];
                        return ClientStockCard(
                          vehicle: item,
                          badgeCount: 0,
                          onPreApproval: () async {
                            final approved = await showLoanApprovalSheet(
                              context,
                              vehicle: item,
                            );
                            if (approved == true) {
                              Navigator.pop(context);
                              widget.onRefresh();
                            }
                          },
                          onViewReport: () {},
                          onDigitalInspection: () {},
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
