import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/model/add_wanted_list_model.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';

class SaveWantedListing {
  final MyListingsRepository _repository;

  SaveWantedListing(this._repository);

  Future<Either<Failure, WantedListingSaveResponseModel>> call(
    WantedListingRequestModel request,
  ) {
    return _repository.saveWantedListing(request);
  }
}
