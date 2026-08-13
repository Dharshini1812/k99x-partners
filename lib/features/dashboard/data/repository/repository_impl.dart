import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/dashboard/data/model/d_stats_model.dart';
import 'package:dealer/features/dashboard/data/remote_datasource/datasource.dart';
import 'package:dealer/features/dashboard/domain/repository/repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDatasource _dashboardDatasource;

  DashboardRepositoryImpl({required DashboardDatasource dashboardDatasource})
      : _dashboardDatasource = dashboardDatasource;
  @override
  Future<Either<Failure, DashboardStats>> getStats() async {
    try {
      final data = await _dashboardDatasource.getStatsCount();
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }
}
