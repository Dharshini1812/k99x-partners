import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/client/dashboard_client/data/model/kyc_view_model.dart';
import 'package:dealer/features/client/dashboard_client/domain/repository/repository.dart';

class GetClientKycView {
  final ClientRepository repository;
  GetClientKycView(this.repository);

  Future<Either<Failure, ClientKycViewResponseModel>> call(String vehicleId) {
    return repository.getKycView(vehicleId);
  }
}
