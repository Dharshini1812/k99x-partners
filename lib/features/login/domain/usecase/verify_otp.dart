import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/core/usecase/usecase.dart';
import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/domain/repository/repository.dart';

class VerifyOtpUsecase implements UseCase<UserData, VerifyOtpModel> {
  final LoginRepository _repository;

  VerifyOtpUsecase(this._repository);

  @override
  Future<Either<Failure, UserData>> call(VerifyOtpModel params) {
    final result = _repository.verifyOtp(params);
    return result;
  }
}
