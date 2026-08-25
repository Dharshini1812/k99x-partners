// lib/features/upload/presentation/logic/review/review_state.dart

import 'package:dealer/features/upload/data/model/review_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'get_review_state.freezed.dart';

@freezed
class VehicleReviewState with _$VehicleReviewState {
  const factory VehicleReviewState.initial() = _VehicleReviewInitial;
  const factory VehicleReviewState.loading() = _VehicleReviewLoading;
  const factory VehicleReviewState.data(ReviewResponseModel data) =
      _VehicleReviewData;
  const factory VehicleReviewState.error(String msg) = _VehicleReviewError;
}
