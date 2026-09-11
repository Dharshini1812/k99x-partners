import 'package:flutter/material.dart';
import 'inspection_full_image_viewer_page.dart';

class InspectionIssueItem {
  final String title;
  final String imageUrl;
  final String category;

  const InspectionIssueItem({
    required this.title,
    required this.imageUrl,
    this.category = 'Issues',
  });
}

class InspIssuesVerticalPage extends StatefulWidget {
  final String vehicleTitle;
  final int initialIndex;
  final List<InspectionIssueItem> issues;

  const InspIssuesVerticalPage({
    super.key,
    required this.vehicleTitle,
    this.initialIndex = 0,
    required this.issues,
  });

  @override
  State<InspIssuesVerticalPage> createState() => _InspIssuesVerticalPageState();
}

class _InspIssuesVerticalPageState extends State<InspIssuesVerticalPage> {
  int _selectedCategoryIndex = 4; // 'Issues' selected by default
  late final ScrollController _scrollController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Exterior', 'count': 13},
    {'name': 'Interior', 'count': 5},
    {'name': 'Engine &\nTransmission', 'count': 3},
    {'name': 'Tyres', 'count': 5},
    {'name': 'Issues', 'count': 9},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex > 0 &&
          widget.initialIndex < widget.issues.length) {
        _scrollController.animateTo(
          widget.initialIndex * 330.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openFullScreenViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InspectionFullImageViewerPage(
          vehicleTitle: widget.vehicleTitle,
          initialIndex: index,
          items: widget.issues
              .map((e) => FullImageViewerItem(
                    imageUrl: e.imageUrl,
                    title: e.title,
                    category: e.category,
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vehicleTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCategoryTabBar(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: widget.issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.issues[index];
                    return _buildIssueCard(item, index, widget.issues.length);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBiddingBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBar() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final cat = _categories[index];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cat['name']}\n(${cat['count']})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSelected ? const Color(0xFF4C3BCF) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4C3BCF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIssueCard(InspectionIssueItem item, int index, int totalCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openFullScreenViewer(index),
          child: Container(
            height: 260,
            width: double.infinity,
            color: const Color(0xFFF2F2F2),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.directions_car,
                          size: 64, color: Colors.grey),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.directions_car,
                        size: 64, color: Colors.grey),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '(${index + 1}/$totalCount)',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }

  Widget _buildBiddingBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: Colors.black87),
                    SizedBox(width: 4),
                    Text(
                      '01:29:03',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Fair value ₹3,48,000',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const Text(
                      'Current bid ₹ 3,04,000',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE8E5FF)),
                      backgroundColor: const Color(0xFFF2F0FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Auto bid',
                      style: TextStyle(
                          color: Color(0xFF4C3BCF),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4335DE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Bid',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        Text('at ₹3,07,000',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
