import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:dealer/features/client/dashboard_client/domain/repository/repository.dart';

class ApproveLoan {
  final ClientRepository repository;
  ApproveLoan(this.repository);

  Future<Either<Failure, LoanApproveResponseModel>> call(
      LoanApproveRequestModel request) {
    return repository.approveLoan(request);
  }
}
