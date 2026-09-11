import 'package:dealer/features/live_auction/data/model/live_model.dart';

class BidActivityResponse {
  final bool? success;
  final String? message;
  final BidActivityData? data;

  BidActivityResponse({this.success, this.message, this.data});

  factory BidActivityResponse.fromJson(Map<String, dynamic> json) {
    return BidActivityResponse(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null ? BidActivityData.fromJson(json['data']) : null,
    );
  }
}

class BidActivityData {
  final int? winningBidderId;
  final bool? isWinning;
  final dynamic autobid;
  final double? highestBid;
  final int? bidsCount;
  final int? rank;
  final List<BidsModel>? bids;
  final AuctionDetails? auction;

  BidActivityData({
    this.winningBidderId,
    this.isWinning,
    this.autobid,
    this.highestBid,
    this.bidsCount,
    this.rank,
    this.bids,
    this.auction,
  });

  factory BidActivityData.fromJson(Map<String, dynamic> json) {
    return BidActivityData(
      winningBidderId: json['winningBidderId'],
      isWinning: json['isWinning'],
      autobid: json['autobid'],
      highestBid: (json['highestBid'] as num?)?.toDouble(),
      bidsCount: json['bidsCount'],
      rank: json['rank'],
      bids: json['bids'] != null
          ? (json['bids'] as List).map((e) {
              return BidsModel(
                id: e['id'],
                amount: (e['amount'] as num?)?.toDouble(),
                timestamp: e['timestamp'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(e['timestamp'])
                        .toIso8601String()
                    : null,
                dealerId: e['dealerId'],
                isAutoBid: e['isAutoBid'],
                bidderName: e['bidderName'],
              );
            }).toList()
          : null,
      auction: json['auction'] != null
          ? AuctionDetails.fromJson(json['auction'])
          : null,
    );
  }
}

class AuctionDetails {
  final int? id;
  final String? auctionCalendarId;
  final String? vehicleId;
  final String? regno;
  final double? startingPrice;
  final double? currentPrice;
  final String? status;
  final int? totalBids;

  AuctionDetails({
    this.id,
    this.auctionCalendarId,
    this.vehicleId,
    this.regno,
    this.startingPrice,
    this.currentPrice,
    this.status,
    this.totalBids,
  });

  factory AuctionDetails.fromJson(Map<String, dynamic> json) {
    return AuctionDetails(
      id: json['id'],
      auctionCalendarId: json['auctionCalendarId'],
      vehicleId: json['vehicleId'],
      regno: json['regno'],
      startingPrice: (json['startingPrice'] as num?)?.toDouble(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble(),
      status: json['status'],
      totalBids: json['totalBids'],
    );
  }
}
