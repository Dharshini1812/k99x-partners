import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/lender_model.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction_logic.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuctionFilterSheet extends ConsumerStatefulWidget {
  const AuctionFilterSheet({super.key});

  @override
  ConsumerState<AuctionFilterSheet> createState() => _AuctionFilterSheetState();
}

class _AuctionFilterSheetState extends ConsumerState<AuctionFilterSheet> {
  final _makeController = TextEditingController();
  final _regNoController = TextEditingController();
  final _modelController = TextEditingController();

  static final DateTime _maxSelectableDate = DateTime(2027, 12, 31);

  @override
  void initState() {
    super.initState();
    final logic = ref.read(auctionLogic);
    _makeController.text = logic.make;
    _regNoController.text = logic.registrationNumber;
    _modelController.text = logic.model;
    Future.microtask(() {
      ref.read(getStateProvider.notifier).getState();
      ref.read(getLenderProvider.notifier).getLender();
      if (logic.selectedState != null) {
        ref
            .read(getCityProvider.notifier)
            .getCity(id: logic.selectedState!.stateId.toString());
      }
    });
  }

  @override
  void dispose() {
    _makeController.dispose();
    _regNoController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _resetFiltersToDefaults(AuctionLogic logic) {
    final states = ref.read(getStateProvider).whenOrNull(data: (s) => s) ?? [];
    final userStateName = ref.read(dLogic).user?.stateName;
    logic.resetToDefaults(userStateName: userStateName, states: states);
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

  static bool _matchesSearch(LiveAuctionModel vehicle, String query) {
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

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(auctionLogic);
    final stateData = ref.watch(getStateProvider);
    final cityData = ref.watch(getCityProvider);
    final liveAuctionState = ref.watch(liveAuctionNotifier);
    final lenderData = ref.watch(getLenderProvider);

    // Compute actual active matches respecting active tab status and search query
    final matchCount = liveAuctionState.whenOrNull(data: (items) {
          return items
              .where((a) => !_isEnded(a))
              .where((a) {
                if (logic.activeTabStatus == null) return true;
                return (a.status ?? '').trim().toUpperCase() ==
                    logic.activeTabStatus!.toUpperCase();
              })
              .where((a) => _matchesSearch(a, logic.searchQuery))
              .length;
        }) ??
        0;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Refine Results',
                        style: TextStyle(
                          fontSize: 18,
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

              // ── Active Filters summary ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEF0F2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Filters',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                          if (logic.activeFilterCount > 0)
                            GestureDetector(
                              onTap: () => _resetFiltersToDefaults(logic),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        logic.activeFilterCount == 0
                            ? 'No filters applied'
                            : '${logic.activeFilterCount} filter${logic.activeFilterCount == 1 ? '' : 's'} applied',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$matchCount matches shown',
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  children: [
                    _label('State'),
                    stateData.when(
                      initial: () => _dropdownPlaceholder('All States'),
                      loading: () => _dropdownPlaceholder('Loading...'),
                      error: (msg) => _dropdownPlaceholder('All States'),
                      data: (states) => _buildStateDropdown(logic, states),
                    ),
                    const SizedBox(height: 18),
                    _label('City'),
                    cityData.when(
                      initial: () => _dropdownPlaceholder('All Cities'),
                      loading: () => _dropdownPlaceholder('Loading...'),
                      error: (msg) => _dropdownPlaceholder('All Cities'),
                      data: (cities) => _buildCityDropdown(logic, cities),
                    ),
                    const SizedBox(height: 18),
                    _label('Date Range'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            context: context,
                            hint: 'From',
                            value: logic.fromDate,
                            firstDate: DateTime(2000),
                            lastDate: logic.toDate ?? _maxSelectableDate,
                            onChanged: logic.updateFromDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDateField(
                            context: context,
                            hint: 'To',
                            value: logic.toDate,
                            firstDate: logic.fromDate ?? DateTime(2000),
                            lastDate: _maxSelectableDate,
                            onChanged: logic.updateToDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _label('Make'),
                    _textField(_makeController, 'Enter make', logic.updateMake),
                    const SizedBox(height: 18),
                    _label('Registration Number'),
                    _textField(
                      _regNoController,
                      'Search reg. number',
                      logic.updateRegistrationNumber,
                      uppercase: true,
                    ),
                    const SizedBox(height: 18),
                    _label('Model'),
                    _textField(
                        _modelController, 'Enter model', logic.updateModel),
                    const SizedBox(height: 8),
                    const Divider(height: 32),
                    _label('Fuel Type'),
                    ...AuctionLogic.fuelOptions.map((f) => _checkboxRow(
                          label: f,
                          checked: logic.fuelTypes.contains(f),
                          onChanged: (_) => logic.toggleFuelType(f),
                        )),
                    const SizedBox(height: 10),
                    _label('Transmission'),
                    ...AuctionLogic.transmissionOptions.map((t) => _checkboxRow(
                          label: t,
                          checked: logic.transmissions.contains(t),
                          onChanged: (_) => logic.toggleTransmission(t),
                        )),
                    const SizedBox(height: 18),
                    _label('Mileage'),
                    Slider(
                      value: logic.maxMileage,
                      min: 0,
                      max: AuctionLogic.maxMileageCap,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: logic.updateMaxMileage,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('0 km',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF9CA3AF))),
                          Text(
                            logic.maxMileage >= AuctionLogic.maxMileageCap
                                ? '2,00,000+ km'
                                : '${logic.maxMileage.toInt()} km',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _label('Lender'),
                    lenderData.maybeWhen(
                      data: (data) {
                        return Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<LenderModel>(
                              value: logic.selectedLender,
                              isExpanded: true,
                              hint: const Text(
                                'Select Lender',
                                style: TextStyle(fontSize: 13),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              items: data.map((lender) {
                                return DropdownMenuItem<LenderModel>(
                                  value: lender,
                                  child: Text(
                                    lender.lenderName ?? '',
                                  ),
                                );
                              }).toList(),
                              onChanged: (lender) {
                                setState(() {
                                  logic.selectedLender = lender;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      orElse: () => const SizedBox(),
                    ),
                    const SizedBox(height: 18),
                    _label('Status'),
                    _buildStringDropdown(
                      value: logic.selectedStatus,
                      options: AuctionLogic.statusOptions,
                      onChanged: logic.updateStatus,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _resetFiltersToDefaults(logic);
                          _makeController.clear();
                          _regNoController.clear();
                          _modelController.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF374151),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Clear Filters',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        logic.search();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151)),
        ),
      );

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
      );

  Widget _textField(
    TextEditingController c,
    String hint,
    ValueChanged<String> onChanged, {
    bool uppercase = false,
  }) {
    return TextField(
      controller: c,
      onChanged: onChanged,
      textCapitalization:
          uppercase ? TextCapitalization.characters : TextCapitalization.none,
      style: const TextStyle(fontSize: 13.5),
      decoration: _fieldDecoration(hint: hint),
    );
  }

  Widget _dropdownPlaceholder(String label) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(fontSize: 13, color: Colors.black54)),
    );
  }

  Widget _buildStateDropdown(AuctionLogic logic, List<StateModel> states) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StateModel?>(
          value: logic.selectedState,
          isExpanded: true,
          hint: const Text('All States', style: TextStyle(fontSize: 13)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: [
            const DropdownMenuItem<StateModel?>(
                value: null, child: Text('All States')),
            ...states.map((s) => DropdownMenuItem<StateModel?>(
                  value: s,
                  child: Text(s.stateName ?? ''),
                )),
          ],
          onChanged: logic.updateState,
        ),
      ),
    );
  }

  Widget _buildCityDropdown(AuctionLogic logic, List<CityModel> cities) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CityModel?>(
          value: logic.selectedCity,
          isExpanded: true,
          hint: const Text('All Cities', style: TextStyle(fontSize: 13)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: [
            const DropdownMenuItem<CityModel?>(
                value: null, child: Text('All Cities')),
            ...cities.map((c) => DropdownMenuItem<CityModel?>(
                  value: c,
                  child: Text(c.cityName ?? ''),
                )),
          ],
          onChanged: logic.updateCity,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String hint,
    required DateTime? value,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime?> onChanged,
  }) {
    final safeFirst = firstDate.isAfter(lastDate) ? lastDate : firstDate;

    DateTime defaultInitial = DateTime.now();
    if (defaultInitial.isBefore(safeFirst)) defaultInitial = safeFirst;
    if (defaultInitial.isAfter(lastDate)) defaultInitial = lastDate;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? defaultInitial,
          firstDate: safeFirst,
          lastDate: lastDate,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? _formatDate(value) : hint,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      value != null ? Colors.black87 : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Color(0xFF9CA3AF)),
              )
            else
              const Icon(Icons.calendar_today_rounded,
                  size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Widget _buildStringDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }

  Widget _checkboxRow({
    required String label,
    required bool checked,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: checked,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}
