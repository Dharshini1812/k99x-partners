import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';

abstract class UploadRepository {
  Future<Either<Failure, UploadModel>> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  });
}
