import 'package:dealer/features/dashboard/domain/usecase/dashboard_count.dart';
import 'package:dealer/features/dashboard/presentation/logic/stats_count/stats_count_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetStatsCountNotifier extends StateNotifier<StatsCountState> {
  final DashboardCountUsecase _countUsecase;

  GetStatsCountNotifier(
      {required DashboardCountUsecase countUsecase,
      StatsCountState? statsCount,
      x})
      : _countUsecase = countUsecase,
        super(statsCount ?? const StatsCountState.initial());

  Future<void> getDashboardStats() async {
    state = const StatsCountState.loading();

    try {
      final result = await _countUsecase.getStatsCount();

      result.fold(
        (failure) {
          state = StatsCountState.error(failure.msg ?? '');
        },
        (response) {
          state = StatsCountState.data(response);
        },
      );
    } catch (e) {
      state = StatsCountState.error(e.toString());
    }
  }
}
