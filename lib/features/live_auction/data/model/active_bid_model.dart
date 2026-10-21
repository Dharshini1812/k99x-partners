import 'package:dealer/features/live_auction/data/model/new_auction_detail_model.dart';

class ActiveBidsResponse {
  final ActiveBidsData? data;
  final bool success;
  final String? message;

  ActiveBidsResponse({this.data, this.success = false, this.message});

  factory ActiveBidsResponse.fromJson(Map<String, dynamic> json) =>
      ActiveBidsResponse(
        data: json['data'] == null
            ? null
            : ActiveBidsData.fromJson(json['data'] as Map<String, dynamic>),
        success: json['success'] ?? false,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
        'success': success,
        'message': message,
      };
}

class ActiveBidsData {
  final String? tab; // e.g. "active"
  final List<VehicleItem> bids;
  final int totalCount;

  ActiveBidsData({this.tab, this.bids = const [], this.totalCount = 0});

  factory ActiveBidsData.fromJson(Map<String, dynamic> json) => ActiveBidsData(
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
