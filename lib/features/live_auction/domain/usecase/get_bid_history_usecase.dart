// lib/features/my_bids/domain/usecase/get_bid_history_usecase.dart

import 'package:dealer/features/live_auction/data/model/bid_history_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetBidHistoryUseCase {
  final AuctionRepository repository;

  GetBidHistoryUseCase(this.repository);

  Future<BidHistoryResponse> call() {
    return repository.getBidHistory();
  }
}
