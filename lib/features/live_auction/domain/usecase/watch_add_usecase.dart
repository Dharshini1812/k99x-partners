import 'package:dealer/features/live_auction/data/model/watch_request_model.dart';
import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class UpdateWatchlistUseCase {
  final AuctionRepository repository;

  UpdateWatchlistUseCase({required this.repository});

  Future<WatchlistUpdateResponseModel> call(
      WatchlistUpdateRequestModel request) {
    return repository.updateWatchlist(request);
  }
}
