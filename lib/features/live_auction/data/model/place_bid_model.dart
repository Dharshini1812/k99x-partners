// lib/features/live_auction/data/model/place_bid_model.dart

class PlaceBidResponseModel {
  final int? rank;
  final bool success;
  final String message;

  PlaceBidResponseModel({
    this.rank,
    required this.success,
    required this.message,
  });

  factory PlaceBidResponseModel.fromJson(Map<String, dynamic> json) {
    return PlaceBidResponseModel(
      rank: json['data']?['rank'],
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
