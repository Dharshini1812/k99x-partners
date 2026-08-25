// lib/features/upload/domain/usecase/complete_vehicle_listing.dart

import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart'; // ADAPT
import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart';

class CompleteVehicleListing {
  final UploadRepository repository;
  CompleteVehicleListing(this.repository);

  Future<Either<Failure, CompleteVehicleResponseModel>> call(
      CompleteVehicleRequestModel request) {
    return repository.completeVehicleListing(request);
  }
}
