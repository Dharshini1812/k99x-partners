// lib/features/upload/presentation/logic/complete_vehicle/complete_vehicle_state.dart

import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'complete_review_state.freezed.dart';

@freezed
class CompleteVehicleState with _$CompleteVehicleState {
  const factory CompleteVehicleState.initial() = _CompleteVehicleInitial;
  const factory CompleteVehicleState.loading() = _CompleteVehicleLoading;
  const factory CompleteVehicleState.data(CompleteVehicleResponseModel data) =
      _CompleteVehicleData;
  const factory CompleteVehicleState.error(String msg) = _CompleteVehicleError;
}
