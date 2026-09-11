import 'package:flutter/material.dart';

class FullImageViewerItem {
  final String imageUrl;
  final String title;
  final String category;

  const FullImageViewerItem({
    required this.imageUrl,
    required this.title,
    this.category = 'Issues',
  });
}

class InspectionFullImageViewerPage extends StatefulWidget {
  final String vehicleTitle;
  final int initialIndex;
  final List<FullImageViewerItem> items;

  const InspectionFullImageViewerPage({
    super.key,
    required this.vehicleTitle,
    this.initialIndex = 0,
    required this.items,
  });

  @override
  State<InspectionFullImageViewerPage> createState() =>
      _InspectionFullImageViewerPageState();
}

class _InspectionFullImageViewerPageState
    extends State<InspectionFullImageViewerPage> {
  late PageController _pageController;
  late ScrollController _thumbScrollController;
  late int _currentIndex;

  final TransformationController _transformController =
      TransformationController();
  bool _isZoomed = false;
  Offset _doubleTapPosition = Offset.zero;

  final List<String> _tabs = [
    'Exterior',
    'Interior',
    'Engine & Trans.',
    'Tyres',
    'Issues'
  ];
  int _selectedTabIndex = 4;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _thumbScrollController = ScrollController();

    _transformController.addListener(() {
      final scale = _transformController.value.getMaxScaleOnAxis();
      final zoomed = scale > 1.01;
      if (zoomed != _isZoomed) {
        setState(() => _isZoomed = zoomed);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(_currentIndex);
    });
  }

  void _scrollToThumbnail(int index) {
    if (_thumbScrollController.hasClients) {
      _thumbScrollController.animateTo(
        index * 76.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbScrollController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECEC),
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
          // Main Interactive Viewer with Pinch-to-Zoom
          Positioned.fill(
            bottom: 70,
            child: PageView.builder(
              controller: _pageController,
              // Disable page swipe while zoomed in, so pan gestures
              // go to InteractiveViewer instead of switching images.
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _scrollToThumbnail(index);
                _resetZoom();
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return GestureDetector(
                  onDoubleTapDown: (details) =>
                      _doubleTapPosition = details.localPosition,
                  onDoubleTap: () {
                    if (_transformController.value != Matrix4.identity()) {
                      _resetZoom();
                    } else {
                      _transformController.value = Matrix4.identity()
                        ..translate(
                          -_doubleTapPosition.dx,
                          -_doubleTapPosition.dy,
                        )
                        ..scale(2.5);
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    onInteractionEnd: (_) {
                      final scale =
                          _transformController.value.getMaxScaleOnAxis();
                      if (scale < 1.05) {
                        _resetZoom();
                      }
                    },
                    child: Center(
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.directions_car,
                                size: 100,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.directions_car,
                              size: 100,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Tabs & Thumbnail Strip
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withOpacity(0.95),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _tabs.asMap().entries.map((entry) {
                          final isSelected = entry.key == _selectedTabIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTabIndex = entry.key),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF4C3BCF)
                                    : Colors.black54,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        controller: _thumbScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = _currentIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4C3BCF)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                color: Colors.grey.shade300,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: widget.items[index].imageUrl.isNotEmpty
                                  ? Image.network(
                                      widget.items[index].imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
