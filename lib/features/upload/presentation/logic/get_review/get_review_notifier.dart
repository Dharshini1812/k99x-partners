// lib/features/upload/presentation/logic/review/review_notifier.dart

import 'package:dealer/features/upload/data/model/review_response_model.dart';
import 'package:dealer/features/upload/domain/usecase/get_vehicle_review.dart'; // ADAPT
import 'package:dealer/features/upload/presentation/logic/get_review/get_review_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VehicleReviewNotifier extends StateNotifier<VehicleReviewState> {
  final GetVehicleReview _usecase;

  VehicleReviewNotifier({required GetVehicleReview usecase})
      : _usecase = usecase,
        super(const VehicleReviewState.initial());

  Future<ReviewResponseModel?> fetchReview(String vehicleId) async {
    state = const VehicleReviewState.loading();

    try {
      final result = await _usecase(vehicleId);

      return result.fold(
        (failure) {
          state = VehicleReviewState.error(
              failure.msg ?? 'Could not load review details');
          return null;
        },
        (data) {
          state = VehicleReviewState.data(data);
          return data;
        },
      );
    } catch (e) {
      state = VehicleReviewState.error(e.toString());
      return null;
    }
  }
}
