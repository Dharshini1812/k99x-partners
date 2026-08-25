import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
import 'package:dealer/features/upload/domain/usecase/add_vehicle_data.dart';
import 'package:dealer/features/upload/presentation/logic/add_vehicle_data/add_vehicle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddVehicleNotifier extends StateNotifier<AddVehicleState> {
  final AddvehicleDataUsecase _addvehicleDataUsecase;

  AddVehicleNotifier(
      {required AddvehicleDataUsecase addvehicleDataUsecase,
      AddVehicleState? initState})
      : _addvehicleDataUsecase = addvehicleDataUsecase,
        super(initState ?? const AddVehicleState.initial());

  Future<AddVehicleResponseModel?> addVehicleData(
      {required AddVehicleRequestModel data}) async {
    state = const AddVehicleState.initial();

    try {
      final result = await _addvehicleDataUsecase.addVehicleData(data);
      return result.fold(
        (l) {
          state = AddVehicleState.error(l.msg ?? '');
          return null;
        },
        (r) {
          state = AddVehicleState.data(r);
          return r;
        },
      );
    } catch (e) {
      state = AddVehicleState.error(e.toString());
      return null;
    }
  }
}
