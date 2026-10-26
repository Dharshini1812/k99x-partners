import 'package:dealer/features/live_auction/data/model/meta_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class InsertMetaBidUseCase {
  final AuctionRepository repository;

  InsertMetaBidUseCase(this.repository);

  Future<MetaBidResponseModel> call(InsertMetaBidRequestModel request) {
    return repository.insertBid(request);
  }
}
