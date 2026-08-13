import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class UploadDatasource {
  Future<UploadModel> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  });
}

class UploadDatasourceImpl implements UploadDatasource {
  final Ref ref;

  UploadDatasourceImpl({required this.ref});

  @override
  Future<UploadModel> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  }) async {
    final response = await ref.read(apiService).uploadImage(
          url: Url.uploadUrl,
          vehicleId: vehicleId,
          imageType: mediaType,
          filePath: filePath,
        );

    return UploadModel.fromJson(response.data);
  }
}
