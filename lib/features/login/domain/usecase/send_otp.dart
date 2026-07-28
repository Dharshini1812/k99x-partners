import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/core/usecase/usecase.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/domain/repository/repository.dart';

class SendOtpUsecase implements UseCase<SendOtpModel, SendOtpModel> {
  final LoginRepository _repository;
  SendOtpUsecase(this._repository);

  @override
  Future<Either<Failure, SendOtpModel>> call(SendOtpModel params) async {
    final result = await _repository.sendOtp(params);
    return result;
  }
}
