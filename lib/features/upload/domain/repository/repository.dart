import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/data/model/edit_vehicle_response_model.dart';
import 'package:dealer/features/upload/data/model/review_response_model.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';

abstract class UploadRepository {
  Future<Either<Failure, UploadModel>> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  });

  Future<Either<Failure, AddVehicleResponseModel>> addVehickeData(
      AddVehicleRequestModel data);
  Future<Either<Failure, ReviewResponseModel>> getVehicleReview(
      String vehicleId);
  Future<Either<Failure, CompleteVehicleResponseModel>> completeVehicleListing(
      CompleteVehicleRequestModel request);
  Future<Either<Failure, EditVehicleResponseModel>> getVehicleForEdit(
      String vehicleId);
}
