import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/live_auction/data/model/auction_vehicle.dart';
import 'package:flutter/material.dart';

@AutoRoute()
class VehicleDetailPage extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailPage({super.key, required this.vehicleId});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = mockVehicleFeed.firstWhere(
      (v) => v.id == widget.vehicleId,
      orElse: () => mockVehicleFeed.first,
    );

    final isAuction = vehicle.listingType == ListingType.auction;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          vehicle.title,
          style: const TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black87),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.black87),
              onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Dummy Hero Header
                Stack(
                  children: [
                    Container(
                      height: 230,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(Icons.directions_car,
                            size: 80, color: Colors.grey.shade400),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('ID: ${vehicle.id}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${vehicle.location}  ${vehicle.rtoCode}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 130,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Text('Engine sound ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            Icon(Icons.volume_up,
                                color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Thumbnails Bar (Dummy Placeholders)
                Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 5,
                    itemBuilder: (context, idx) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 65,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.image,
                          size: 24, color: Colors.grey.shade400),
                    ),
                  ),
                ),

                // Specs & Ratings
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(vehicle.specs,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 16),

                      // Rating Indicators
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildScoreChip("Exterior", vehicle.exteriorRating),
                            _buildScoreChip("Engine", vehicle.engineRating),
                            _buildScoreChip("AC", vehicle.acRating),
                            _buildScoreChip(
                                "Electricals", vehicle.electricalsRating),
                            _buildScoreChip("Steering", vehicle.steeringRating),
                          ],
                        ),
                      ),

                      const Divider(height: 32),
                      _buildInfoSection("Documents", vehicle.documents),
                      const Divider(height: 32),
                      _buildInfoSection("Other information", vehicle.otherInfo),
                      const Divider(height: 32),
                      _buildInfoSection(
                          "Registration and fitness", vehicle.registrationInfo),
                      const Divider(height: 32),

                      // Inspection Category Lists
                      const Text("Exterior",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      _buildInspectionCategory(
                          "Structure", vehicle.structureChecks),
                      _buildInspectionCategory(
                          "Other components", vehicle.otherComponentsChecks),
                      _buildInspectionCategory(
                          "Windshield & lights", vehicle.windshieldChecks),
                      _buildInspectionCategory("Engine", vehicle.engineChecks),
                      _buildInspectionCategory(
                          "Exterior panels", vehicle.exteriorPanelsChecks),
                      _buildInspectionCategory("Tyres", vehicle.tyresChecks),
                      _buildInspectionCategory(
                          "Electricals & Interiors", vehicle.electricalsChecks),
                      _buildInspectionCategory(
                          "Steering & Suspension", vehicle.steeringChecks),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating "GO TO TOP" Button
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _scrollToTop,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('GO TO TOP',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Bid / Buy Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(vehicle.timeRemaining,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Fair value ${vehicle.fairValue}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                          Text(
                            '${isAuction ? 'Current bid' : 'OCB price'} ${vehicle.currentPriceOrBid}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3E8FF),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isAuction ? 'Auto bid' : 'Quote price',
                            style: const TextStyle(
                                color: Color(0xFF5D24AA),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D24AA),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: isAuction
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Bid',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    Text('at ${vehicle.bidIncrementPrice}',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10)),
                                  ],
                                )
                              : const Text('Buy',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, double rating) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
                '${rating.toStringAsFixed(rating.truncateToDouble() == rating ? 0 : 1)} ★',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...data.entries.map((e) {
          final isExpired = e.value.toLowerCase().contains("expired");
          final isValid = e.value.toLowerCase().contains("valid");

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key,
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isExpired
                        ? Colors.red
                        : isValid
                            ? Colors.teal
                            : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInspectionCategory(
      String categoryName, List<InspectionDefect> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(categoryName,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.isPassed ? Icons.check_circle : Icons.remove_circle,
                    color: item.isPassed ? Colors.teal : Colors.amber.shade800,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        if (item.subtitle != null)
                          Text(item.subtitle!,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (item.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            item.hasVideo ? Icons.play_arrow : Icons.image,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            )),
        const SizedBox(height: 10),
      ],
    );
  }
}
