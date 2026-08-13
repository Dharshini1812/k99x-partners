import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_state.freezed.dart';

@freezed
class UploadState with _$UploadState {
  const factory UploadState.initial() = _UploadStateInitial;

  const factory UploadState.loading() = _UploadStateLoading;

  const factory UploadState.data(UploadModel data) = _UploadStateData;

  const factory UploadState.error(String msg) = _UploadStateError;
}
