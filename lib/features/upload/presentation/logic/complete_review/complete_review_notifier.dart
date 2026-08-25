import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/domain/usecase/complete_review.dart';
import 'package:dealer/features/upload/presentation/logic/complete_review/complete_review_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompleteVehicleNotifier extends StateNotifier<CompleteVehicleState> {
  final CompleteVehicleListing _usecase;

  CompleteVehicleNotifier({required CompleteVehicleListing usecase})
      : _usecase = usecase,
        super(const CompleteVehicleState.initial());

  Future<CompleteVehicleResponseModel?> complete(
      CompleteVehicleRequestModel request) async {
    state = const CompleteVehicleState.loading();

    try {
      final result = await _usecase(request);

      return result.fold(
        (failure) {
          state = CompleteVehicleState.error(
              failure.msg ?? 'Could not complete the listing');
          return null;
        },
        (data) {
          state = CompleteVehicleState.data(data);
          return data;
        },
      );
    } catch (e) {
      state = CompleteVehicleState.error(e.toString());
      return null;
    }
  }
}
