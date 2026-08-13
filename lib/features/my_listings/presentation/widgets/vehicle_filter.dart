import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class VehicleFilterBar extends StatefulWidget {
  final void Function(VehicleFilterState filters)? onSearch;
  final void Function(VehicleFilterState filters)? onFilterChanged;
  final void Function()? onClear;

  const VehicleFilterBar(
      {super.key, this.onSearch, this.onFilterChanged, this.onClear});

  @override
  State<VehicleFilterBar> createState() => _VehicleFilterBarState();
}

// KM range bounds — defined once here since both VehicleFilterState and
// the slider widget need them.
const double kKmMin = 0;
const double kKmMax = 150000;

class VehicleFilterState {
  String? make;
  String? year;
  String? model;
  String? owners;
  String? stockAge;
  RangeValues kmRange = const RangeValues(kKmMin, kKmMax);
  String query = '';
}

class _MakeOption {
  final String name;
  final Widget image;
  final Color color;

  _MakeOption(this.name, this.image, this.color);
}

class _VehicleFilterBarState extends State<VehicleFilterBar> {
  final _searchController = TextEditingController();
  final _filters = VehicleFilterState();
  bool _showMoreFilters = false;

  // Debounces the search text box so it auto-searches as you type instead
  // of only firing on Enter/submit or the buried "Search" button. Waits
  // for a pause in typing rather than firing on every keystroke.
  Timer? _searchDebounce;
  static const _searchDebounceDuration = Duration(milliseconds: 400);

  static const _brandColor = Color(0xFF6B4EFF);

  // KM range bounds — snapping to 5,000 km steps.
  static const int _kmDivisions = 30; // (kKmMax - kKmMin) / 5000

  static final _makes = [
    _MakeOption('All', const Icon(Icons.apps_rounded), const Color(0xFF6B4EFF)),
    _MakeOption('Maruti', SvgPicture.asset('images/suzuki.svg'),
        const Color(0xFF2E7D32)),
    _MakeOption('Hyundai', SvgPicture.asset('images/hyundai.svg'),
        const Color(0xFF1565C0)),
    _MakeOption(
        'Tata', SvgPicture.asset('images/tata.svg'), const Color(0xFFC62828)),
    _MakeOption(
        'Honda', Image.asset('images/honda.png'), const Color(0xFFEF6C00)),
    _MakeOption(
        'Toyota', Image.asset('images/toyota.png'), const Color(0xFF00838F)),
    _MakeOption('Kia', Image.asset('images/kia.png'), const Color(0xFF6A1B9A)),
    _MakeOption('Mahindra', Image.asset('images/mahindra.png'),
        const Color(0xFF37474F)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  String _formatKm(double km) {
    final rounded = km.round();
    final s = rounded.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0 && posFromRight % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  bool get _isKmRangeActive =>
      _filters.kmRange.start != kKmMin || _filters.kmRange.end != kKmMax;

  Future<void> _openPicker({
    required String title,
    required List<String> options,
    required String? current,
    required ValueChanged<String?> onPicked,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                ...options.map(
                  (opt) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            opt == current ? FontWeight.w700 : FontWeight.w500,
                        color: opt == current
                            ? _brandColor
                            : const Color(0xFF333333),
                      ),
                    ),
                    trailing: opt == current
                        ? const Icon(Icons.check_circle_rounded,
                            color: _brandColor, size: 20)
                        : null,
                    onTap: () => Navigator.pop(context, opt),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) onPicked(selected == 'All' ? null : selected);
  }

  void _runSearch() {
    _filters.query = _searchController.text;
    widget.onSearch?.call(_filters);
  }

  // Called on every keystroke in the search box. Resets the debounce timer
  // each time so the search only actually fires once typing pauses,
  // instead of hammering onSearch on every character.
  void _onSearchTextChanged(String value) {
    _filters.query = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, _runSearch);
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = [
          _filters.year,
          _filters.model,
          _filters.owners,
          _filters.stockAge,
        ].where((v) => v != null).length +
        (_isKmRangeActive ? 1 : 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search field ─────────────────────────────────────────
          // Now auto-searches as you type (debounced 400ms after the
          // last keystroke), on top of the existing onSubmitted
          // (Enter/Done) and tap-the-icon triggers, which still fire
          // immediately without waiting for the debounce.
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchTextChanged,
              onSubmitted: (_) {
                _searchDebounce?.cancel();
                _runSearch();
              },
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Stock ID, reg no, model...',
                hintStyle: const TextStyle(
                  color: Color(0xFFA3A6AD),
                  fontSize: 13.5,
                ),
                prefixIcon: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _searchDebounce?.cancel();
                    _runSearch();
                  },
                  child: const Icon(Icons.search_rounded,
                      color: Color(0xFFA3A6AD), size: 20),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 6),
          _KmRangeFilter(
            range: _filters.kmRange,
            min: kKmMin,
            max: kKmMax,
            divisions: _kmDivisions,
            isActive: _isKmRangeActive,
            formatKm: _formatKm,
            onChanged: (v) => setState(() => _filters.kmRange = v),
            onChangeEnd: (v) => widget.onFilterChanged?.call(_filters),
          ),

          const SizedBox(height: 5),
          // ── Make: horizontal logo list — ALWAYS visible ─────────
          const Text(
            'MAKE',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF9AA0A6),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _makes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final make = _makes[index];
                final isAll = make.name == 'All';
                final isSelected =
                    isAll ? _filters.make == null : _filters.make == make.name;
                return GestureDetector(
                  onTap: () => setState(() {
                    _filters.make = isAll ? null : make.name;
                    widget.onFilterChanged?.call(_filters);
                  }),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? make.color.withOpacity(0.12)
                              : const Color(0xFFF5F5F8),
                          border: Border.all(
                            color: isSelected ? make.color : Colors.transparent,
                            width: 1.6,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: make.image,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        make.name,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF9AA0A6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // ── Toggle: show/hide the rest of the filters ────────────
          InkWell(
            onTap: () => setState(() => _showMoreFilters = !_showMoreFilters),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded,
                      size: 16,
                      color: activeCount > 0
                          ? _brandColor
                          : const Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(
                    _showMoreFilters ? 'Hide Filters' : 'More Filters',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: activeCount > 0
                          ? _brandColor
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _brandColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  AnimatedRotation(
                    turns: _showMoreFilters ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: Color(0xFF9AA0A6)),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible: pills + KM range + Search/Clear buttons ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _showMoreFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _FilterPill(
                        label: 'Year',
                        value: _filters.year ?? 'All',
                        onTap: () => _openPicker(
                          title: 'Select Year',
                          options: const [
                            'All',
                            '2026',
                            '2025',
                            '2024',
                            '2023',
                            '2022'
                          ],
                          current: _filters.year ?? 'All',
                          onPicked: (v) => setState(() {
                            _filters.year = v;
                            widget.onFilterChanged?.call(_filters);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterPill(
                        label: 'Model',
                        value: _filters.model ?? 'All',
                        onTap: () => _openPicker(
                          title: 'Select Model',
                          options: const [
                            'All',
                            'Alto',
                            'Swift',
                            'Dzire',
                            'Baleno'
                          ],
                          current: _filters.model ?? 'All',
                          onPicked: (v) => setState(() {
                            _filters.model = v;
                            widget.onFilterChanged?.call(_filters);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _FilterPill(
                        label: 'Owners',
                        value: _filters.owners ?? 'All',
                        onTap: () => _openPicker(
                          title: 'Select Owners',
                          options: const ['All', '1', '2', '3+'],
                          current: _filters.owners ?? 'All',
                          onPicked: (v) => setState(() {
                            _filters.owners = v;
                            widget.onFilterChanged?.call(_filters);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterPill(
                        label: 'Stock Age',
                        value: _filters.stockAge ?? 'All',
                        onTap: () => _openPicker(
                          title: 'Select Stock Age',
                          options: const [
                            'All',
                            '< 7 days',
                            '7-15 days',
                            '15-30 days',
                            '30+ days'
                          ],
                          current: _filters.stockAge ?? 'All',
                          onPicked: (v) => setState(() {
                            _filters.stockAge = v;
                            widget.onFilterChanged?.call(_filters);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7B5CFA), Color(0xFF6B4EFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _brandColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () {
                                _searchDebounce?.cancel();
                                _runSearch();
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_rounded,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Search',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _searchDebounce?.cancel();
                          setState(() {
                            _searchController.clear();

                            _filters.query = '';
                            _filters.make = null;
                            _filters.year = null;
                            _filters.model = null;
                            _filters.owners = null;
                            _filters.stockAge = null;
                            _filters.kmRange =
                                const RangeValues(kKmMin, kKmMax);
                          });
                          widget.onClear?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        icon: const Icon(Icons.refresh_rounded,
                            size: 16, color: Color(0xFF6B7280)),
                        label: const Text(
                          'Clear',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KM RANGE FILTER — thin two-thumb range slider styled to read as a
// linear-progress bar (thin track, filled segment between the thumbs)
// rather than a stock Material slider.
// ─────────────────────────────────────────────────────────────────────────────

class _KmRangeFilter extends StatelessWidget {
  final RangeValues range;
  final double min;
  final double max;
  final int divisions;
  final bool isActive;
  final String Function(double) formatKm;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;

  const _KmRangeFilter({
    required this.range,
    required this.min,
    required this.max,
    required this.divisions,
    required this.isActive,
    required this.formatKm,
    required this.onChanged,
    this.onChangeEnd,
  });

  static const _brandColor = Color(0xFF6B4EFF);

  @override
  Widget build(BuildContext context) {
    final isFullRange = range.start == min && range.end == max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'KM RANGE',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF9AA0A6),
              ),
            ),
            const Spacer(),
            Text(
              isFullRange
                  ? 'Any'
                  : '${formatKm(range.start)} – ${formatKm(range.end)} km',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? _brandColor : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: _brandColor,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 1,
            ),
            thumbColor: _brandColor,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            overlayColor: _brandColor.withOpacity(0.12),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 1,
            ),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            min: min,
            max: max,
            divisions: divisions,
            values: range,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatKm(min)} km',
                style: const TextStyle(fontSize: 10, color: Color(0xFF9AA0A6)),
              ),
              Text(
                '${formatKm(max)} km',
                style: const TextStyle(fontSize: 10, color: Color(0xFF9AA0A6)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER PILL — compact dropdown-style button that opens a bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != 'All';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6B4EFF).withOpacity(0.07)
              : const Color(0xFFF5F5F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6B4EFF).withOpacity(0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Color(0xFF9AA0A6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF6B4EFF)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color:
                  isActive ? const Color(0xFF6B4EFF) : const Color(0xFF9AA0A6),
            ),
          ],
        ),
      ),
    );
  }
}
