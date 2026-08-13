import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/datasource/remote_datasource.dart';
import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';

class MyListingsRepositoryImpl implements MyListingsRepository {
  final ListingDataSource dataSource;

  MyListingsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, VehicleResponse>> getMyListings(
      {int? offset, int? limit}) async {
    try {
      final response =
          await dataSource.getMyListings(offset: offset, limit: limit);
      return Right(response);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleResponse>> getLiveListings({
    int? offset,
    int? limit,
    LiveStockFilter? filter,
  }) async {
    try {
      final response =
          await dataSource.getLiveListings(offset: offset, limit: limit);
      return Right(response);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycSubmitResponse>> addKycUpload(
      KycSubmitRequest? request) async {
    try {
      final response = await dataSource.addKyc(request);
      return Right(response);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }
}
