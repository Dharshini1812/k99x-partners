import 'package:dealer/features/upload/domain/usecase/vehicle_edit.dart';
import 'package:dealer/features/upload/presentation/logic/upload_edit/vehicle_edit_state.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart'; // editVehicleProvider + toListingModel()
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditVehicleFetchNotifier extends StateNotifier<EditVehicleFetchState> {
  final GetVehicleForEdit _usecase;
  final Ref ref;

  EditVehicleFetchNotifier(
      {required GetVehicleForEdit usecase, required this.ref})
      : _usecase = usecase,
        super(const EditVehicleFetchState.initial());
  Future<bool> fetchForEdit(String vehicleId) async {
    state = const EditVehicleFetchState.loading();

    try {
      final result = await _usecase(vehicleId);

      return result.fold(
        (failure) {
          state = EditVehicleFetchState.error(
              failure.msg ?? 'Could not load vehicle details');
          return false;
        },
        (response) {
          state = EditVehicleFetchState.data(response);

          final current = ref.read(editVehicleProvider);
          ref.read(editVehicleProvider.notifier).state = (
            model: response.vehicle.toListingModel(),
            refreshKey: current.refreshKey + 1,
          );

          return true;
        },
      );
    } catch (e) {
      state = EditVehicleFetchState.error(e.toString());
      return false;
    }
  }
}
