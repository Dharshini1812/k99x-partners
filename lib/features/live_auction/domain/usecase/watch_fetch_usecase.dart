import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetWatchlistUseCase {
  final AuctionRepository repository;

  GetWatchlistUseCase({required this.repository});

  Future<WatchlistFetchResponseModel> call() {
    return repository.getWatchlist();
  }
}
