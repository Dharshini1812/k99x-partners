// lib/features/upload/presentation/logic/edit_vehicle/edit_vehicle_fetch_state.dart

import 'package:dealer/features/upload/data/model/edit_vehicle_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_edit_state.freezed.dart';

@freezed
class EditVehicleFetchState with _$EditVehicleFetchState {
  const factory EditVehicleFetchState.initial() = _EditVehicleFetchInitial;
  const factory EditVehicleFetchState.loading() = _EditVehicleFetchLoading;
  const factory EditVehicleFetchState.data(EditVehicleResponseModel data) =
      _EditVehicleFetchData;
  const factory EditVehicleFetchState.error(String msg) =
      _EditVehicleFetchError;
}
