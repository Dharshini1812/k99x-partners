import 'package:dealer/features/dashboard/data/remote_datasource/datasource.dart';
import 'package:dealer/features/dashboard/data/repository/repository_impl.dart';
import 'package:dealer/features/dashboard/domain/repository/repository.dart';
import 'package:dealer/features/dashboard/domain/usecase/dashboard_count.dart';
import 'package:dealer/features/dashboard/presentation/logic/stats_count/stats_count_notifier.dart';
import 'package:dealer/features/dashboard/presentation/logic/stats_count/stats_count_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _dashboardDatasource =
    Provider<DashboardDatasource>((ref) => DashboardDatasourceImpl(ref: ref));
final _dRepository = Provider<DashboardRepository>((ref) =>
    DashboardRepositoryImpl(
        dashboardDatasource: ref.read(_dashboardDatasource)));

final _dusecase = Provider<DashboardCountUsecase>((ref) =>
    DashboardCountUsecase(dashboardRepository: ref.read(_dRepository)));

final dStatsProvider =
    StateNotifierProvider<GetStatsCountNotifier, StatsCountState>(
        (ref) => GetStatsCountNotifier(countUsecase: ref.read(_dusecase)));
