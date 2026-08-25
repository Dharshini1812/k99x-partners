import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'add_vehicle_state.freezed.dart';

@freezed
class AddVehicleState with _$AddVehicleState {
  const factory AddVehicleState.initial() = _AddVehicleStateInitial;
  const factory AddVehicleState.loading() = _AddVehicleStateLoading;
  const factory AddVehicleState.data(AddVehicleResponseModel data) =
      _AddVehicleStateData;
  const factory AddVehicleState.error(String msg) = _AddVehicleStateError;
}
