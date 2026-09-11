// lib/features/live_auction/data/model/auto_bid_model.dart

class AutoBidResponseModel {
  final bool success;
  final String message;

  AutoBidResponseModel({
    required this.success,
    required this.message,
  });

  factory AutoBidResponseModel.fromJson(Map<String, dynamic> json) {
    return AutoBidResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
