// lib/features/upload/domain/usecase/get_vehicle_for_edit.dart

import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart'; // ADAPT
import 'package:dealer/features/upload/data/model/edit_vehicle_response_model.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart'; // ADAPT

class GetVehicleForEdit {
  final UploadRepository repository;
  GetVehicleForEdit(this.repository);

  Future<Either<Failure, EditVehicleResponseModel>> call(String vehicleId) {
    return repository.getVehicleForEdit(vehicleId);
  }
}
