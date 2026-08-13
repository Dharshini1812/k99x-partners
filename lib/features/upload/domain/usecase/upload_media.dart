import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart';

class UploadMediaUseCase {
  final UploadRepository repository;

  UploadMediaUseCase(this.repository);

  Future<Either<Failure, UploadModel>> call({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  }) {
    return repository.uploadMedia(
      vehicleId: vehicleId,
      mediaType: mediaType,
      filePath: filePath,
    );
  }
}
