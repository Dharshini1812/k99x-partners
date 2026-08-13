import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';

class MyListUsecase {
  final MyListingsRepository repository;

  MyListUsecase({required this.repository});
  Future<Either<Failure, VehicleResponse>> getMyListings(
      {int? offset, int? limit}) async {
    return await repository.getMyListings(offset: offset, limit: limit);
  }
}
