import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/dashboard/data/model/d_stats_model.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getStats();
}
