import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_detail_state.freezed.dart';

@freezed
class VehicleDetailState with _$VehicleDetailState {
  const factory VehicleDetailState.initial() = _Initial;
  const factory VehicleDetailState.loading() = _Loading;
  const factory VehicleDetailState.loaded(VehicleDetailResponse vehicleDetail) =
      _Loaded;
  const factory VehicleDetailState.error(String message) = _Error;
}
