import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'get_state_state.freezed.dart';

@freezed
class GetStateState with _$GetStateState {
  const factory GetStateState.initial() = _GetStateStateInitial;
  const factory GetStateState.loading() = _GetStateStateLoading;
  const factory GetStateState.data(List<StateModel> data) = _GetStateStateData;
  const factory GetStateState.error(String msg) = _GetStateStateError;
}
