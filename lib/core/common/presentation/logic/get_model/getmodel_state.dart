import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'getmodel_state.freezed.dart';

@freezed
class GetModelState with _$GetModelState {
  const factory GetModelState.initial() = _GetModelStateInitial;
  const factory GetModelState.loading() = _GetModelStateLoading;
  const factory GetModelState.data(List<ModelModel> data) = _GetModelStateData;
  const factory GetModelState.error(String msg) = _GetModelStateError;
}
