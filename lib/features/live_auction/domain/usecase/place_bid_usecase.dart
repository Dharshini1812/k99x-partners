// lib/features/live_auction/domain/usecase/place_bid.dart

import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class PlaceBidUsecase {
  final AuctionRepository bidRepository;
  PlaceBidUsecase({required this.bidRepository});

  Future<PlaceBidResponseModel> call({
    required String vehicleId,
    required double bidAmount,
  }) {
    return bidRepository.placeBid(vehicleId: vehicleId, bidAmount: bidAmount);
  }
}
