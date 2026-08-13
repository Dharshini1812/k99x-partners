import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';

class Addkyc {
  final MyListingsRepository _repository;

  Addkyc({required MyListingsRepository repository}) : _repository = repository;
  Future<Either<Failure, KycSubmitResponse>> addKyc(
      KycSubmitRequest? request) async {
    return await _repository.addKycUpload(request);
  }
}
