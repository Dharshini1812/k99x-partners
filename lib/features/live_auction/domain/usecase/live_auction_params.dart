// lib/features/auction/data/model/live_auction_params.dart

class LiveAuctionParams {
  final int? stateId;
  final int? cityId;
  final int? lenderId;
  final int? categoryId;
  final String? status; // e.g. 'UPCOMING', 'LIVE', 'DRAFT' — null = All status
  final DateTime? fromDate;
  final DateTime? toDate;

  const LiveAuctionParams({
    this.stateId,
    this.cityId,
    this.lenderId,
    this.categoryId,
    this.status,
    this.fromDate,
    this.toDate,
  });

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, String> toQueryParams() {
    final map = <String, String>{};
    if (stateId != null) map['stateId'] = '$stateId';
    if (cityId != null) map['cityId'] = '$cityId';
    if (lenderId != null) map['lenderId'] = '$lenderId';
    if (categoryId != null) map['categoryId'] = '$categoryId';
    if (status != null && status!.isNotEmpty) map['status'] = status!;
    if (fromDate != null) map['fromDate'] = _fmt(fromDate!);
    if (toDate != null) map['toDate'] = _fmt(toDate!);
    return map;
  }
}
