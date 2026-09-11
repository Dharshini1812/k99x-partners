import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_detail_vehcile_usecase.dart';
import 'vehicle_detail_state.dart';

class VehicleDetailNotifier extends StateNotifier<VehicleDetailState> {
  final GetVehicleDetailUseCase _getDetailVehicleUseCase;

  VehicleDetailNotifier(this._getDetailVehicleUseCase)
      : super(const VehicleDetailState.initial());

  Future<void> fetchVehicleDetail(String vehicleId) async {
    state = const VehicleDetailState.loading();
    try {
      final response = await _getDetailVehicleUseCase(vehicleId);
      if (response.success) {
        state = VehicleDetailState.loaded(response);
      } else {
        state = VehicleDetailState.error(response.message);
      }
    } catch (e) {
      state = VehicleDetailState.error(e.toString());
    }
  }
}
