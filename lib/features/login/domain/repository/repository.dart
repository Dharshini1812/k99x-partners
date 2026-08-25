import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/login/data/model/logout_model.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:dealer/features/login/data/model/verify_model.dart';

abstract class LoginRepository {
  Future<Either<Failure, SendOtpModel>> sendOtp(SendOtpModel model);
  Future<Either<Failure, UserData>> verifyOtp(VerifyOtpModel model);
  Future<Either<Failure, LogoutResponseModel>> logout();
}
