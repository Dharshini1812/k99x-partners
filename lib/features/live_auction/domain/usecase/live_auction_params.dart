// lib/features/live_auction/domain/usecase/live_auction_params.dart

/// Params for `GET admin/live/auction/json`[cite: 18].
class LiveAuctionParams {
  final int? stateId;
  final int? cityId;
  final int? lenderId;
  final int? categoryId;
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? mode;

  // ── Vehicle Filter Fields ───────────────────────────────────────
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
    this.mode,
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
    if (status != null && status!.isNotEmpty) params['status'] = status;
    if (fromDate != null) params['fromDate'] = _fmtDate(fromDate!);
    if (toDate != null) params['toDate'] = _fmtDate(toDate!);
    if (mode != null && mode!.isNotEmpty) params['mode'] = mode;

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
