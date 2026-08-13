import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';

abstract class MyListingsRepository {
  Future<Either<Failure, VehicleResponse>> getMyListings(
      {int? offset, int? limit});
  Future<Either<Failure, VehicleResponse>> getLiveListings(
      {int? offset, int? limit});

  Future<Either<Failure, KycSubmitResponse>> addKycUpload(
      KycSubmitRequest? request);
}
