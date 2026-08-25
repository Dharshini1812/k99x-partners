import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/client/dashboard_client/data/model/c_dashboard_stats.dart';
import 'package:dealer/features/client/dashboard_client/data/model/kyc_view_model.dart';
import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';

abstract class ClientRepository {
  Future<Either<Failure, ClientDashboardResponseModel>> getDashboard();
  Future<Either<Failure, ClientStocksResponseModel>> getStocks({
    required int page,
    int limit = 10,
  });
  Future<Either<Failure, LoanApproveResponseModel>> approveLoan(
      LoanApproveRequestModel request);
  Future<Either<Failure, ClientKycViewResponseModel>> getKycView(
      String vehicleId);
}
