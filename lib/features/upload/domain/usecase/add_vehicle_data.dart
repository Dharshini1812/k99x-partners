import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';

import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart';

class AddvehicleDataUsecase {
  final UploadRepository _repository;

  AddvehicleDataUsecase({required UploadRepository repository})
      : _repository = repository;

  Future<Either<Failure, AddVehicleResponseModel>> addVehicleData(
      AddVehicleRequestModel data) async {
    return await _repository.addVehickeData(data);
  }
}
