// lib/features/live_auction/domain/usecase/get_live_auction_vehicles_usecase.dart

import 'package:dealer/features/live_auction/data/datasource/datasource.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetLiveAuctionVehiclesUsecase {
  final AuctionRepository auctionRepository;
  GetLiveAuctionVehiclesUsecase({required this.auctionRepository});

  Future<List<LiveAuctionModel>> call(LiveAuctionVehiclesParams params) {
    return auctionRepository.getLiveAuctionVehicles(params);
  }
}
