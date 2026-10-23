import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'update_vehicle_state.freezed.dart';

@freezed
class UpdateVehicleState with _$UpdateVehicleState {
  const factory UpdateVehicleState.initial() = _Initial;
  const factory UpdateVehicleState.loading() = _Loading;
  const factory UpdateVehicleState.success(AddVehicleResponseModel response) =
      _Success;
  const factory UpdateVehicleState.error(String message) = _Error;
}
