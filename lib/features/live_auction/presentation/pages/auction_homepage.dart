import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/core/theme/colors.dart';

import 'package:dealer/features/live_auction/data/model/auction_vehicle.dart';
import 'package:dealer/features/live_auction/presentation/widgets/vehicle_cards.dart';
import 'package:flutter/material.dart';

@AutoRoute()
class AuctionHomePage extends StatefulWidget {
  const AuctionHomePage({super.key});

  @override
  State<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends State<AuctionHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter by Tab type and Search Query in real-time
    final auctionList = mockVehicleFeed.where((v) {
      final isAuction = v.listingType == ListingType.auction;
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.rtoCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.id.contains(_searchQuery);
      return isAuction && matchesSearch;
    }).toList();

    final ocbList = mockVehicleFeed.where((v) {
      final isOcb = v.listingType == ListingType.oneClickBuy;
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.rtoCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.id.contains(_searchQuery);
      return isOcb && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Purple Header Section
            Container(
              color: const Color(0xFFF2EDF8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // Working Search Field + Icon
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Search car, RTO, or ID',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: 20,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 18, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '1 RTO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 22,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill(Icons.tune, null),
                        const SizedBox(width: 6),
                        _buildFilterPill(Icons.swap_vert, null),
                        const SizedBox(width: 6),
                        _buildFilterPill(Icons.verified, "PRIME"),
                        const SizedBox(width: 6),
                        _buildFilterPill(null, "No Transit Cost"),
                        const SizedBox(width: 6),
                        _buildFilterPill(null, "4+ Eng"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Auctions & One Click Buy TabBar
                  // Auctions & One Click Buy TabBar (Equally Spaced 50/50 Width)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable:
                          false, // 👈 Ensures equal 50/50 width distribution
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      tabs: [
                        Tab(
                          child: _buildCustomTabBadge(
                            count: "${auctionList.length}",
                            title: "Auctions",
                            index: 0,
                          ),
                        ),
                        Tab(
                          child: _buildCustomTabBadge(
                            count: "${ocbList.length}",
                            title: "One click buy",
                            index: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TabBarView Content (Swipeable List)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVehicleList(auctionList, "No auctions found"),
                  _buildVehicleList(ocbList, "No one-click cars found"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(List<VehicleModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final vehicle = list[index];
        return VehicleCard(
          vehicle: vehicle,
          onTap: () {
            context.router.push(VehicleDetailRoute(vehicleId: vehicle.id));
          },
        );
      },
    );
  }

  Widget _buildCustomTabBadge({
    required String count,
    required String title,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isSelected = _tabController.index == index;
        return Container(
          width: double.infinity, // 👈 Fills the equal 50% width
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // 👈 Centers badge + label
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(IconData? icon, String? label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.black87),
          if (icon != null && label != null) const SizedBox(width: 4),
          if (label != null)
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
