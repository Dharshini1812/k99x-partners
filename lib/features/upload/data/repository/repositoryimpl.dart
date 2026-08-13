import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/upload/data/datasource/remote_datasource.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';
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
}
