import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final auctionLogic = ChangeNotifierProvider((ref) => AuctionLogic(ref: ref));

class AuctionLogic extends ChangeNotifier {
  final Ref ref;

  AuctionLogic({required this.ref});

  // ── Location / lender / date filters ────────────────────────────
  String searchQuery = '';
  StateModel? selectedState;
  CityModel? selectedCity;
  dynamic selectedLender;
  DateTime? fromDate;
  DateTime? toDate;
  String? activeTabStatus;

  bool _userStateApplied = false;

  /// True while [fromDate]/[toDate] are still the auto-seeded "last one
  /// month" range set on app launch, rather than something the user
  /// picked in the filter sheet. The dates are still sent to the API
  /// either way (search() doesn't check this) — this flag only affects
  /// [activeFilterCount] and the "Date range ×" chip, which must NOT
  /// treat the launch default as a filter the user applied.
  bool isDefaultDateRange = false;

  // ── "Refine Results" fields ─────────────────────────────────────
  String? yearFrom;
  String? yearTo;
  String make = '';
  String registrationNumber = '';
  String model = '';
  final Set<String> fuelTypes = {};
  final Set<String> transmissions = {};
  double maxMileage = maxMileageCap;
  String condition = 'Any';
  String seller = 'All sellers';
  String ownership = 'All ownership';

  static const List<String> fuelOptions = ['Petrol', 'Diesel', 'Electric'];
  static const List<String> transmissionOptions = ['Automatic', 'Manual'];
  static const List<String> conditionOptions = [
    'Any',
    'Excellent',
    'Good',
    'Average',
    'Poor'
  ];
  static const List<String> sellerOptions = [
    'All sellers',
    'Dealer',
    'Individual',
    'Bank/NBFC'
  ];
  static const List<String> ownershipOptions = [
    'All ownership',
    '1st Owner',
    '2nd Owner',
    '3rd Owner',
    '3+ Owners'
  ];
  static const double maxMileageCap = 200000;

  // ── Category / status (used for tab wiring) ─────────────────────
  static const List<String> categoryOptions = [
    'All categories',
    'Two wheeler',
    'Three wheeler',
    'Four wheeler',
    'Commercial vehicle',
    'Farm equipment',
    'Construction equipment',
  ];
  static const List<String> statusOptions = [
    'All status',
    'Live',
    'Upcoming',
    'Sold',
  ];
  String selectedCategory = categoryOptions.first;
  String selectedStatus = statusOptions.first;

  // ── Update methods ────────────────────────────────────────────────
  void updateSearchQuery(String v) {
    searchQuery = v;
    notifyListeners();
  }

  void updateState(StateModel? v) {
    selectedState = v;
    selectedCity = null;
    notifyListeners();
    if (v != null) {
      ref.read(getCityProvider.notifier).getCity(id: v.stateId.toString());
    }
  }

  void updateCity(CityModel? v) {
    selectedCity = v;
    notifyListeners();
  }

  void updateLender(dynamic v) {
    selectedLender = v;
    notifyListeners();
  }

  void updateCategory(String v) {
    selectedCategory = v;
    notifyListeners();
  }

  void updateStatus(String v) {
    selectedStatus = v;
    notifyListeners();
  }

  /// Seeds the initial "last one month up to today" range used for the
  /// very first fetch on app launch. The dates are still sent to the API
  /// as normal — this only marks the range as a default, not a
  /// user-applied filter — see [isDefaultDateRange].
  void setDefaultDateRange(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    isDefaultDateRange = true;
    notifyListeners();
  }

  void updateFromDate(DateTime? v) {
    fromDate = v;
    // The user is now explicitly choosing a date, so this is no longer
    // just the launch default — keep the range sane too: if "to" is now
    // before "from", clear it.
    isDefaultDateRange = false;
    if (v != null && toDate != null && toDate!.isBefore(v)) {
      toDate = null;
    }
    notifyListeners();
  }

  void updateToDate(DateTime? v) {
    toDate = v;
    isDefaultDateRange = false;
    notifyListeners();
  }

  void updateYearFrom(String? v) {
    yearFrom = v;
    notifyListeners();
  }

  void updateYearTo(String? v) {
    yearTo = v;
    notifyListeners();
  }

  void updateMake(String v) {
    make = v;
    notifyListeners();
  }

  void updateRegistrationNumber(String v) {
    registrationNumber = v;
    notifyListeners();
  }

  void updateModel(String v) {
    model = v;
    notifyListeners();
  }

  void toggleFuelType(String type) {
    fuelTypes.contains(type) ? fuelTypes.remove(type) : fuelTypes.add(type);
    notifyListeners();
  }

  void toggleTransmission(String type) {
    transmissions.contains(type)
        ? transmissions.remove(type)
        : transmissions.add(type);
    notifyListeners();
  }

  void updateMaxMileage(double v) {
    maxMileage = v;
    notifyListeners();
  }

  void updateCondition(String v) {
    condition = v;
    notifyListeners();
  }

  void updateSeller(String v) {
    seller = v;
    notifyListeners();
  }

  void updateOwnership(String v) {
    ownership = v;
    notifyListeners();
  }

  /// Count of distinct active filters, for the "Active Filters" summary.
  /// The auto-seeded launch date range is deliberately excluded — see
  /// [isDefaultDateRange]. It's still sent to the API by search(); it
  /// just isn't shown to the user as something they "applied".
  int get activeFilterCount {
    int count = 0;
    if (selectedState != null) count++;
    if (selectedCity != null) count++;
    if ((fromDate != null || toDate != null) && !isDefaultDateRange) count++;
    if (yearFrom != null || yearTo != null) count++;
    if (make.trim().isNotEmpty) count++;
    if (registrationNumber.trim().isNotEmpty) count++;
    if (model.trim().isNotEmpty) count++;
    if (fuelTypes.isNotEmpty) count++;
    if (transmissions.isNotEmpty) count++;
    if (maxMileage < maxMileageCap) count++;
    if (condition != conditionOptions.first) count++;
    if (seller != sellerOptions.first) count++;
    if (ownership != ownershipOptions.first) count++;
    return count;
  }

  /// Resets every filter to exactly what it was when the app was first
  /// opened — the default "last one month" date range and the dealer's
  /// own state (if one matches) — rather than to a blank slate. This is
  /// what "Clear all" should call.
  ///
  /// [userStateName] and [states] are the same inputs
  /// applyUserDefaultState() takes; pass them from wherever the caller
  /// already has them (AuctionFilterBar has both via dLogic and
  /// getStateProvider).
  void resetToDefaults({
    required String? userStateName,
    required List<StateModel> states,
  }) {
    selectedCity = null;
    selectedLender = null;
    yearFrom = null;
    yearTo = null;
    make = '';
    registrationNumber = '';
    model = '';
    fuelTypes.clear();
    transmissions.clear();
    maxMileage = maxMileageCap;
    condition = conditionOptions.first;
    seller = sellerOptions.first;
    ownership = ownershipOptions.first;
    selectedCategory = categoryOptions.first;
    selectedStatus = statusOptions.first;

    // Restore the same launch-default date range: 2 months before today
    // through 2 months after today.
    final today = DateTime.now();
    final twoMonthsAgo = DateTime(today.year, today.month - 2, today.day);
    final twoMonthsAhead = DateTime(today.year, today.month + 2, today.day);
    fromDate = twoMonthsAgo;
    toDate = twoMonthsAhead;
    isDefaultDateRange = true;

    // Let the dealer's own state be re-applied, same as on launch.
    selectedState = null;
    _userStateApplied = false;
    notifyListeners();

    if (!_applyMatchingState(userStateName, states)) {
      // No matching state to restore (e.g. profile/list unavailable) —
      // still refresh the list with the restored date range.
      search();
    }
  }

  /// Shared by [applyUserDefaultState] and [resetToDefaults]: finds and
  /// applies the StateModel matching [userStateName], if any. Returns
  /// whether a match was found and applied (and search() called).
  bool _applyMatchingState(String? userStateName, List<StateModel> states) {
    if (userStateName == null || userStateName.trim().isEmpty) return false;

    final match = states.where((s) =>
        (s.stateName ?? '').trim().toLowerCase() ==
        userStateName.trim().toLowerCase());
    if (match.isEmpty) return false;

    _userStateApplied = true;
    updateState(match.first); // also triggers city fetch + notifyListeners
    search();
    return true;
  }

  /// Called once, as soon as both the user's profile and the states list
  /// are available, to default the auction list to the dealer's own state.
  /// Does nothing if already applied once, or if the dealer has no
  /// stateName on their profile, or if no matching StateModel is found.
  void applyUserDefaultState(String? userStateName, List<StateModel> states) {
    if (_userStateApplied) return;
    _applyMatchingState(userStateName, states);
  }

  /// Called by AuctionHomePage on tab switch.
  void setActiveTabStatus(String? status) {
    activeTabStatus = status;
    notifyListeners();
    search();
  }

  int? _categoryId(String label) {
    const map = {
      'Two wheeler': 1,
      'Three wheeler': 2,
      'Four wheeler': 3,
      'Commercial vehicle': 4,
      'Farm equipment': 5,
      'Construction equipment': 6,
    };
    return map[label];
  }

  String? _statusValue(String label) {
    if (label == statusOptions.first) return null;
    return label.toUpperCase();
  }

  void search() {
    final explicitStatus = _statusValue(selectedStatus);
    final params = LiveAuctionParams(
      stateId: selectedState?.stateId,
      cityId: selectedCity?.cityId,
      lenderId: selectedLender?.id, // adjust field name to your lender model
      categoryId: _categoryId(selectedCategory),
      status: explicitStatus ?? activeTabStatus,
      fromDate: fromDate,
      toDate: toDate,
      // ── Previously dropped — now passed through to the API. See the
      // NOTE in LiveAuctionParams.toQueryParams() re: confirming the
      // actual backend query-param names for each of these.
      make: make,
      registrationNumber: registrationNumber,
      model: model,
      yearFrom: yearFrom,
      yearTo: yearTo,
      fuelTypes: fuelTypes,
      transmissions: transmissions,
      maxMileage: maxMileage < maxMileageCap ? maxMileage : null,
      condition: condition,
      seller: seller,
      ownership: ownership,
    );
    ref.read(liveAuctionNotifier.notifier).getLiveAuctions(params);
  }
}
