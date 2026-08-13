import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/dashboard/data/model/d_stats_model.dart';
import 'package:dealer/features/dashboard/domain/repository/repository.dart';

class DashboardCountUsecase {
  final DashboardRepository _dashboardRepository;

  DashboardCountUsecase({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository;

  Future<Either<Failure, DashboardStats>> getStatsCount() async {
    return await _dashboardRepository.getStats();
  }
}
