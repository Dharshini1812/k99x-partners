import 'package:dealer/features/dashboard/data/model/d_stats_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'stats_count_state.freezed.dart';

@freezed
class StatsCountState with _$StatsCountState {
  const factory StatsCountState.initial() = _StatsCountStateInitial;
  const factory StatsCountState.loading() = _StatsCountStateLoading;
  const factory StatsCountState.data(DashboardStats data) =
      _StatsCountStateData;
  const factory StatsCountState.error(String msg) = _StatsCountStateError;
}
