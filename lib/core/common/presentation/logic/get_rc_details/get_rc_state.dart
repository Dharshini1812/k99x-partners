import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'get_rc_state.freezed.dart';

@freezed
class GetRcState with _$GetRcState {
  const factory GetRcState.initial() = _GetRcStateInitial;
  const factory GetRcState.loading() = _GetRcStateLoading;
  const factory GetRcState.data(RCDetailsModel data) = _GetRcStateData;
  const factory GetRcState.error(String msg) = _GetRcStateError;
}
