import 'package:dealer/features/my_listings/data/model/car_model.dart';
import 'package:flutter/material.dart';

enum _CardTab { pricing, details, market }

class CarInspectionCard extends StatefulWidget {
  final Car? car;
  final VoidCallback? onRatingAdjust;

  const CarInspectionCard({
    super.key,
    this.car,
    this.onRatingAdjust,
  });

  @override
  State<CarInspectionCard> createState() => _CarInspectionCardState();
}

class _CarInspectionCardState extends State<CarInspectionCard> {
  bool _isExpanded = false;
  _CardTab _activeTab = _CardTab.pricing;

  // Demo hardcoded category ratings.
  static const double _exteriorRating = 5;
  static const double _interiorRating = 5;
  static const double _engineRating = 5;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _selectTab(_CardTab tab) {
    setState(() => _activeTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Summary Row: Thumbnail + Info + Rating buttons ────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Thumbnail(imagePath: 'images/img2.webp'),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2026 MARUTI SUZUKI ALTO LXI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Petrol · Manual · SUV',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '13,000 km · ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '1',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' Owner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                            TextSpan(
                              text: ' · ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'TN98AV45',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _RatingButton(
                      label: '+5',
                      isPositive: true,
                      onPressed: () => widget.onRatingAdjust?.call(),
                    ),
                    const SizedBox(height: 6),
                    _RatingButton(
                      label: '−1',
                      isNegative: true,
                      onPressed: () => widget.onRatingAdjust?.call(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Category Ratings + Expand Icon (same row) ──────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            child: Row(
              children: [
                Expanded(
                  child: _CategoryRatingChip(
                    label: 'Exterior',
                    rating: _exteriorRating,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _CategoryRatingChip(
                    label: 'Interior',
                    rating: _interiorRating,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _CategoryRatingChip(
                    label: 'Engine',
                    rating: _engineRating,
                  ),
                ),
                const SizedBox(width: 5),
                _ExpandIconButton(
                  isExpanded: _isExpanded,
                  onPressed: _toggleExpanded,
                ),
              ],
            ),
          ),

          // ── Tabs + Table (only when expanded) ──────────────────────
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _TabsRow(
              activeTab: _activeTab,
              onSelect: _selectTab,
            ),
            _CardTable(activeTab: _activeTab),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THUMBNAIL WITH LIVE TAG
// ─────────────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String imagePath;

  const _Thumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.directions_car_rounded,
              size: 32,
              color: Color(0xFFCCCCCC),
            ),
          ),
        ),
        Positioned(
          top: -6,
          left: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY RATING CHIP (Exterior / Interior / Engine)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryRatingChip extends StatelessWidget {
  final String label;
  final double rating;

  const _CategoryRatingChip({
    required this.label,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A6416),
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              size: 13,
              color: Color(0xFFF39C12),
            ),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A6416),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RATING BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _RatingButton extends StatelessWidget {
  final String label;
  final bool isNegative;
  final bool isPositive;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    this.isNegative = false,
    this.isPositive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: isNegative ? 27 : 40,
          height: isNegative ? 27 : 40,
          decoration: BoxDecoration(
            color: isNegative
                ? const Color(0xFFFEF5F4)
                : isPositive
                    ? const Color(0xFFF1FAF0)
                    : Colors.white,
            border: Border.all(
              color: isNegative
                  ? const Color(0xFFF0B0AA)
                  : isPositive
                      ? const Color(0xFFB3E5B3)
                      : const Color(0xFFE0E0E0),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isNegative ? 14 : 21,
                color: isNegative
                    ? const Color(0xFFE74C3C)
                    : isPositive
                        ? const Color(0xFF27AE60)
                        : const Color(0xFF0F0F0F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPAND ICON BUTTON (sits in the ratings row, far right)
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandIconButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;

  const _ExpandIconButton({
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 22,
            color: Colors.black,
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABS ROW (functional — switches active tab)
// ─────────────────────────────────────────────────────────────────────────────

class _TabsRow extends StatelessWidget {
  final _CardTab activeTab;
  final ValueChanged<_CardTab> onSelect;

  const _TabsRow({
    required this.activeTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Pricing',
            isActive: activeTab == _CardTab.pricing,
            onTap: () => onSelect(_CardTab.pricing),
          ),
          _TabItem(
            label: 'Pre Approved',
            isActive: activeTab == _CardTab.details,
            onTap: () => onSelect(_CardTab.details),
          ),
          _TabItem(
            label: 'Others',
            isActive: activeTab == _CardTab.market,
            onTap: () => onSelect(_CardTab.market),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color:
                      isActive ? const Color(0xFF0F4C7D) : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF0F4C7D) : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE (2-column key/value rows — content swaps based on active tab)
// ─────────────────────────────────────────────────────────────────────────────

class _CardTable extends StatelessWidget {
  final _CardTab activeTab;

  const _CardTable({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final rows = _rowsForTab(activeTab);

    return Column(
      children: [
        for (int i = 0; i < rows.length; i++)
          _TableRow(
            left: rows[i].$1,
            right: rows[i].$2,
            isLast: i == rows.length - 1,
          ),
      ],
    );
  }

  List<(Widget, Widget)> _rowsForTab(_CardTab tab) {
    switch (tab) {
      case _CardTab.pricing:
        return [
          (
            const _TableCell(label: 'Selling Price', value: '₹5,68,767'),
            const _TableCell(
              label: 'Valuation',
              value: '₹3,79,722',
              valueColor: Color(0xFFF39C12),
            ),
          ),
          (
            const _TableCell(
                label: 'Avg Selling', value: '₹5,68,767', small: true),
            const _TableCell(
              label: 'Last Sold',
              value: '₹0',
              small: true,
              valueColor: Color(0xFF888888),
            ),
          ),
        ];

      case _CardTab.details:
        return [
          (
            const _TableCell(label: 'Stock ID', value: 'K99X0123', small: true),
            const _TableCell(
                label: 'Registration', value: 'TN98AV4575', small: true),
          ),
          (
            const _TableCell(
                label: 'Location', value: 'Chennai, TN', small: true),
            const _TableCell(label: 'Type', value: 'SUV', small: true),
          ),
        ];

      case _CardTab.market:
        return [
          (
            const _TableCell(
              label: 'Status',
              value: 'Live',
              valueColor: Color(0xFF27AE60),
              small: true,
            ),
            const _TableCell(
                label: 'Listed', value: '27 Jul 2026', small: true),
          ),
        ];
    }
  }
}

class _TableRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final bool isLast;

  const _TableRow({
    required this.left,
    required this.right,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(14))
            : null,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: left,
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFF0F0F0)),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String label;
  final String value;
  final bool small;
  final Color? valueColor;

  const _TableCell({
    required this.label,
    required this.value,
    this.small = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 13 : 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1A1A1A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
