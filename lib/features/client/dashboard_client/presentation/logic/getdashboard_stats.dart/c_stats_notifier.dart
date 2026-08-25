// lib/features/client/presentation/logic/client_dashboard_notifier.dart

import 'package:dealer/features/client/dashboard_client/domain/usecase/client_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/getdashboard_stats.dart/c_stats_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientDashboardNotifier extends StateNotifier<ClientDashboardState> {
  final GetClientDashboard _usecase;

  ClientDashboardNotifier({required GetClientDashboard usecase})
      : _usecase = usecase,
        super(const ClientDashboardState.initial());

  Future<void> fetch() async {
    state = const ClientDashboardState.loading();

    final result = await _usecase();

    result.fold(
      (failure) {
        state = ClientDashboardState.error(
            failure.msg ?? 'Could not load dashboard stats');
      },
      (response) {
        state = ClientDashboardState.data(response);
      },
    );
  }
}
