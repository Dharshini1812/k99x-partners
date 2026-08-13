import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';

class LiveListUsecase {
  final MyListingsRepository repository;

  LiveListUsecase({required this.repository});
  Future<Either<Failure, VehicleResponse>> getLiveListings({
    int? offset,
    int? limit,
    LiveStockFilter? filter,
  }) async {
    return await repository.getLiveListings(offset: offset, limit: limit);
  }
}
