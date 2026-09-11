import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class EnableAutoBidUsecase {
  final AuctionRepository bidRepository;
  EnableAutoBidUsecase({required this.bidRepository});

  Future<AutoBidResponseModel> call({
    required String vehicleId,
    required double maxBidAmount,
  }) {
    return bidRepository.enableAutoBid(
        vehicleId: vehicleId, maxBidAmount: maxBidAmount);
  }
}
