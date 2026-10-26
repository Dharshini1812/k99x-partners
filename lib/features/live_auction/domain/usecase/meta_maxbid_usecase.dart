import 'package:dealer/features/live_auction/data/model/meta_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetMetaHighestBidUseCase {
  final AuctionRepository repository;

  GetMetaHighestBidUseCase(this.repository);

  Future<MetaBidResponseModel> call({
    required String eventId,
    required String loanNo,
  }) {
    return repository.getHighestBid(
      eventId: eventId,
      loanNo: loanNo,
    );
  }
}
