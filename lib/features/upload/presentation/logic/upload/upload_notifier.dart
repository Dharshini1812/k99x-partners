import 'package:dealer/features/upload/domain/usecase/upload_media.dart';
import 'package:dealer/features/upload/presentation/logic/upload/upload_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadNotifier extends StateNotifier<UploadState> {
  final UploadMediaUseCase uploadMediaUseCase;

  UploadNotifier(this.uploadMediaUseCase) : super(const UploadState.initial());

  Future<void> uploadMedia({
    required String vehicleId,
    required String mediaType,
    required String filePath,
  }) async {
    state = const UploadState.loading();

    final result = await uploadMediaUseCase(
      vehicleId: vehicleId,
      mediaType: mediaType,
      filePath: filePath,
    );

    result.fold(
      (failure) {
        state = UploadState.error(failure.msg ?? '');
      },
      (data) {
        state = UploadState.data(data);
      },
    );
  }

  void reset() {
    state = const UploadState.initial();
  }
}
