// lib/features/live_auction/domain/usecase/live_auction_params.dart

/// Params for `GET auction-live/json`. Sent as query params to the
/// existing search endpoint that AuctionLogic.search() calls whenever
/// any Refine Results filter is active.
///
/// ⚠️ CONFIRM WITH BACKEND before relying on this: the query-param
/// *names* below for make/regNo/model/fuel/transmission/maxMileage/
/// condition/seller/ownership/yearFrom/yearTo are best guesses based on
/// the field names already in AuctionLogic — they are NOT confirmed
/// against the actual API contract the way `status`, `stateId`, `cityId`,
/// `fromDate`, `toDate` are (those match existing working calls). Update
/// the string literals in toQueryParams() to match whatever your backend
/// actually expects; nothing else needs to change once you do.
class LiveAuctionParams {
  final int? stateId;
  final int? cityId;
  final int? lenderId;
  final int? categoryId;
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;

  // ── Previously dropped fields — now carried through ──────────────
  final String? make;
  final String? registrationNumber;
  final String? model;
  final String? yearFrom;
  final String? yearTo;
  final Set<String> fuelTypes;
  final Set<String> transmissions;
  final double? maxMileage;
  final String? condition;
  final String? seller;
  final String? ownership;

  const LiveAuctionParams({
    this.stateId,
    this.cityId,
    this.lenderId,
    this.categoryId,
    this.status,
    this.fromDate,
    this.toDate,
    this.make,
    this.registrationNumber,
    this.model,
    this.yearFrom,
    this.yearTo,
    this.fuelTypes = const {},
    this.transmissions = const {},
    this.maxMileage,
    this.condition,
    this.seller,
    this.ownership,
  });

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (stateId != null) params['stateId'] = stateId.toString();
    if (cityId != null) params['cityId'] = cityId.toString();
    if (lenderId != null) params['lenderId'] = lenderId.toString();
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    if (status != null) params['status'] = status;
    if (fromDate != null) params['fromDate'] = _fmtDate(fromDate!);
    if (toDate != null) params['toDate'] = _fmtDate(toDate!);

    // ── Newly wired-in fields ───────────────────────────────────────
    // Param names here are placeholders — confirm actual names with
    // backend and update the string literal on the left of each line.
    if (make != null && make!.trim().isNotEmpty) {
      params['make'] = make!.trim();
    }
    if (registrationNumber != null && registrationNumber!.trim().isNotEmpty) {
      params['regNo'] = registrationNumber!.trim();
    }
    if (model != null && model!.trim().isNotEmpty) {
      params['model'] = model!.trim();
    }
    if (yearFrom != null && yearFrom!.trim().isNotEmpty) {
      params['yearFrom'] = yearFrom!.trim();
    }
    if (yearTo != null && yearTo!.trim().isNotEmpty) {
      params['yearTo'] = yearTo!.trim();
    }
    if (fuelTypes.isNotEmpty) {
      // Comma-separated, e.g. "Petrol,Diesel" — confirm backend expects
      // a single joined string vs. repeated ?fuel=Petrol&fuel=Diesel.
      params['fuel'] = fuelTypes.join(',');
    }
    if (transmissions.isNotEmpty) {
      params['transmission'] = transmissions.join(',');
    }
    if (maxMileage != null) {
      params['maxMileage'] = maxMileage!.toInt().toString();
    }
    if (condition != null && condition != 'Any') {
      params['condition'] = condition;
    }
    if (seller != null && seller != 'All sellers') {
      params['seller'] = seller;
    }
    if (ownership != null && ownership != 'All ownership') {
      params['ownership'] = ownership;
    }

    return params;
  }
}
