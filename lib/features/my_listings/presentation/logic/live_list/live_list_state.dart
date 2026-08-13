import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'live_list_state.freezed.dart';

@freezed
class LiveListState with _$LiveListState {
  const factory LiveListState.initial() = _LiveListStateInitial;
  const factory LiveListState.loading() = _LiveListStateLoading;
  const factory LiveListState.data(VehicleResponse data) = _LiveListStateData;
  const factory LiveListState.error(String msg) = _LiveListStateError;
}
