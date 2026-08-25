import 'package:dealer/features/client/dashboard_client/data/model/c_dashboard_stats.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'c_stats_state.freezed.dart';

@freezed
class ClientDashboardState with _$ClientDashboardState {
  const factory ClientDashboardState.initial() = _ClientDashboardInitial;
  const factory ClientDashboardState.loading() = _ClientDashboardLoading;
  const factory ClientDashboardState.data(ClientDashboardResponseModel data) =
      _ClientDashboardData;
  const factory ClientDashboardState.error(String msg) = _ClientDashboardError;
}
