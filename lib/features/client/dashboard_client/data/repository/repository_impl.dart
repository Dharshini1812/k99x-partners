import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/client/dashboard_client/data/datasource/remote_datasource.dart';
import 'package:dealer/features/client/dashboard_client/data/model/c_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/data/model/kyc_view_model.dart';
import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:dealer/features/client/dashboard_client/domain/repository/repository.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientDataSource dataSource;
  ClientRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, ClientDashboardResponseModel>> getDashboard() async {
    try {
      final result = await dataSource.getDashboard();
      return Right(result);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientStocksResponseModel>> getStocks({
    required int page,
    int limit = 10,
  }) async {
    try {
      final result = await dataSource.getStocks(page: page, limit: limit);
      return Right(result);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanApproveResponseModel>> approveLoan(
      LoanApproveRequestModel request) async {
    try {
      final result = await dataSource.approveLoan(request);
      return Right(result);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientKycViewResponseModel>> getKycView(
      String vehicleId) async {
    try {
      final result = await dataSource.getKycView(vehicleId);
      return Right(result);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }
}
