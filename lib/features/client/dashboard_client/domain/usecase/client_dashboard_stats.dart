import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/client/dashboard_client/data/model/c_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/domain/repository/repository.dart';

class GetClientDashboard {
  final ClientRepository repository;
  GetClientDashboard(this.repository);

  Future<Either<Failure, ClientDashboardResponseModel>> call() {
    return repository.getDashboard();
  }
}
