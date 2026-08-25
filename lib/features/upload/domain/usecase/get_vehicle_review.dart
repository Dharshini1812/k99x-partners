// lib/features/upload/domain/usecase/get_vehicle_review.dart

import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart'; // ADAPT
import 'package:dealer/features/upload/data/model/review_response_model.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart';

class GetVehicleReview {
  final UploadRepository repository;
  GetVehicleReview(this.repository);

  Future<Either<Failure, ReviewResponseModel>> call(String vehicleId) {
    return repository.getVehicleReview(vehicleId);
  }
}
