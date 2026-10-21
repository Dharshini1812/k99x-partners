// lib/features/my_bids/domain/usecase/get_active_bids_usecase.dart

import 'package:dealer/features/live_auction/data/model/active_bid_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetActiveBidsUseCase {
  final AuctionRepository repository;

  GetActiveBidsUseCase(this.repository);

  Future<ActiveBidsResponse> call() {
    return repository.getActiveBids();
  }
}
