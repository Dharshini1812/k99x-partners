import 'package:dealer/core/common/data/model/lender_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'get_lender_state.freezed.dart';

@freezed
class GetLenderState with _$GetLenderState {
  const factory GetLenderState.initial() = _GetLenderStateInitial;
  const factory GetLenderState.loading() = _GetLenderStateLoading;
  const factory GetLenderState.data(List<LenderModel> data) =
      _GetLenderStateData;
  const factory GetLenderState.error(String msg) = _GetLenderStateError;
}
