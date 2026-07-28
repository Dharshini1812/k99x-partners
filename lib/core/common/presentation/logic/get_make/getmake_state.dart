import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'getmake_state.freezed.dart';

@freezed
class GetMakeState with _$GetMakeState {
  const factory GetMakeState.initial() = _GetMakeStateInitial;
  const factory GetMakeState.loading() = _GetMakeStateLoading;
  const factory GetMakeState.data(List<MakeModel> data) = _GetMakeStateData;
  const factory GetMakeState.error(String msg) = _GetMakeStateError;
}
