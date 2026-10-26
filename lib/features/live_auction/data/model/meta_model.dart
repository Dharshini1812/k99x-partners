// lib/features/meta_bid/data/model/meta_bid_model.dart

class MetaBidData {
  final num? highestBidAmount;
  final String? winningStatus;

  MetaBidData({
    this.highestBidAmount,
    this.winningStatus,
  });

  factory MetaBidData.fromJson(Map<String, dynamic> json) {
    return MetaBidData(
      highestBidAmount: json['highestBidAmount'] as num?,
      winningStatus: json['winningStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'highestBidAmount': highestBidAmount,
        'winningStatus': winningStatus,
      };
}

class MetaBidResponseModel {
  final int? status;
  final bool success;
  final String message;
  final MetaBidData? data;
  final int? statusCode;

  MetaBidResponseModel({
    this.status,
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory MetaBidResponseModel.fromJson(Map<String, dynamic> json) {
    return MetaBidResponseModel(
      status: json['status'] as int?,
      success:
          json['success'] ?? (json['status'] == 200 || json['status'] == 201),
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MetaBidData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      statusCode: json['statusCode'] as int?,
    );
  }
}

class InsertMetaBidRequestModel {
  final String eventId;
  final String loanNo;
  final String bidderId;
  final double bidAmount;
  final int lenderId;

  InsertMetaBidRequestModel({
    required this.eventId,
    required this.loanNo,
    required this.bidderId,
    required this.bidAmount,
    required this.lenderId,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'loanNo': loanNo,
        'bidderId': bidderId,
        'bidAmount': bidAmount,
        'lenderId': lenderId,
      };
}
