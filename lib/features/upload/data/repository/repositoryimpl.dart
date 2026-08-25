import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/upload/data/datasource/remote_datasource.dart';
import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/data/model/edit_vehicle_response_model.dart';
import 'package:dealer/features/upload/data/model/review_response_model.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart';

import 'package:dio/dio.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadDatasource datasource;

  UploadRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UploadModel>> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  }) async {
    try {
      final response = await datasource.uploadMedia(
        vehicleId: vehicleId,
        mediaType: mediaType,
        filePath: filePath,
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(
        CustomFailure(
            msg: e.response?.data["message"] ?? "Media upload failed"),
      );
    } catch (e) {
      return Left(
        CustomFailure(msg: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, AddVehicleResponseModel>> addVehickeData(
      AddVehicleRequestModel data) async {
    try {
      final response = await datasource.addVehicleData(data);
      return Right(response);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewResponseModel>> getVehicleReview(
      String vehicleId) async {
    try {
      final result = await datasource.getVehicleReview(vehicleId);
      return Right(result);
    } on DioException catch (e) {
      return Left(CustomFailure(
        msg:
            e.response?.data?['message'] ?? e.message ?? 'Something went wrong',
      ));
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompleteVehicleResponseModel>> completeVehicleListing(
      CompleteVehicleRequestModel request) async {
    try {
      final result = await datasource.completeVehicleListing(request);
      return Right(result);
    } on DioException catch (e) {
      return Left(CustomFailure(
        msg:
            e.response?.data?['message'] ?? e.message ?? 'Something went wrong',
      ));
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EditVehicleResponseModel>> getVehicleForEdit(
      String vehicleId) async {
    try {
      final result = await datasource.getVehicleForEdit(vehicleId);
      return Right(result);
    } on DioException catch (e) {
      return Left(CustomFailure(
        msg:
            e.response?.data?['message'] ?? e.message ?? 'Something went wrong',
      ));
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }
}
