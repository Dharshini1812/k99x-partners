import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'my_list_state.freezed.dart';

@freezed
class MyListState with _$MyListState {
  const factory MyListState.initial() = _MyListStateInitial;
  const factory MyListState.loading() = _MyListStateLoading;
  const factory MyListState.data(VehicleResponse data) = _MyListStateData;
  const factory MyListState.error(String msg) = _MyListStateError;
}
