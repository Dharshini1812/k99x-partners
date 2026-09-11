import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';

class GetLiveAuctionUsecase {
  final AuctionRepository auctionRepository;
  GetLiveAuctionUsecase({required this.auctionRepository});

  Future<List<LiveAuctionModel>> call(LiveAuctionParams params) {
    return auctionRepository.getLiveAuctions(params);
  }
}
