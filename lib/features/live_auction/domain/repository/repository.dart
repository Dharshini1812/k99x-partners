// lib/features/auction/domain/repository/auction_repository.dart

import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';

abstract class AuctionRepository {
  Future<List<LiveAuctionModel>> getLiveAuctions(LiveAuctionParams params);
  Future<PlaceBidResponseModel> placeBid({
    required String vehicleId,
    required double bidAmount,
  });

  Future<AutoBidResponseModel> enableAutoBid({
    required String vehicleId,
    required double maxBidAmount,
  });
  Future<Either<Failure, BidActivityData>> getBidActivity(String vehicleId);
  Future<VehicleDetailResponse> getVehicleDetail(String vehicleId);
}
