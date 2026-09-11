import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/live_auction/data/datasource/datasource.dart';
import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionDatasource datasource;
  AuctionRepositoryImpl({required this.datasource});

  @override
  Future<List<LiveAuctionModel>> getLiveAuctions(
    LiveAuctionParams params,
  ) {
    return datasource.getLiveAuctions(params);
  }

  @override
  Future<PlaceBidResponseModel> placeBid({
    required String vehicleId,
    required double bidAmount,
  }) {
    return datasource.placeBid(vehicleId: vehicleId, bidAmount: bidAmount);
  }

  @override
  Future<AutoBidResponseModel> enableAutoBid({
    required String vehicleId,
    required double maxBidAmount,
  }) {
    return datasource.enableAutoBid(
        vehicleId: vehicleId, maxBidAmount: maxBidAmount);
  }

  @override
  Future<Either<Failure, BidActivityData>> getBidActivity(
      String vehicleId) async {
    try {
      final response = await datasource.getBidActivity(vehicleId);
      if (response.statusCode == 200 && response.data != null) {
        final parsed = BidActivityResponse.fromJson(response.data);
        if (parsed.data != null) {
          return Right(parsed.data!);
        }
        return const Left(CustomFailure(msg: 'No activity data found'));
      }
      return Left(CustomFailure(
          msg: response.statusMessage ?? 'Failed to load activity'));
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<VehicleDetailResponse> getVehicleDetail(String vehicleId) async {
    try {
      return await datasource.getVehicleDetail(vehicleId);
    } catch (e) {
      rethrow;
    }
  }
}
