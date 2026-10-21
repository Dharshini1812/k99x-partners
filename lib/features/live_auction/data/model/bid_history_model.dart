// Model for "Bid history fetched successfully" response
// GET /dealer/bid/my-bids/history?status=OUTBID&fromDate=...&toDate=...
// Each bid reuses VehicleItem from event_vehicles_response.dart.

import 'package:dealer/features/live_auction/data/model/new_auction_detail_model.dart';

class BidHistoryResponse {
  final BidHistoryData? data;
  final bool success;
  final String? message;

  BidHistoryResponse({this.data, this.success = false, this.message});

  factory BidHistoryResponse.fromJson(Map<String, dynamic> json) =>
      BidHistoryResponse(
        data: json['data'] == null
            ? null
            : BidHistoryData.fromJson(json['data'] as Map<String, dynamic>),
        success: json['success'] ?? false,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
        'success': success,
        'message': message,
      };
}

class BidHistoryData {
  final String? tab; // "history"
  final List<VehicleItem> bids;
  final int totalCount;

  BidHistoryData({this.tab, this.bids = const [], this.totalCount = 0});

  factory BidHistoryData.fromJson(Map<String, dynamic> json) => BidHistoryData(
        tab: json['tab'],
        bids: (json['bids'] as List?)
                ?.map((e) => VehicleItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'tab': tab,
        'bids': bids.map((e) => e.toJson()).toList(),
        'totalCount': totalCount,
      };
}
