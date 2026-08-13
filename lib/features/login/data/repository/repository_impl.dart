import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/login/data/datasource/remote_datasource.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/domain/repository/repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  final LoginRemoteDataSource _loginRemoteDataSource;

  LoginRepositoryImpl(this._loginRemoteDataSource);

  @override
  Future<Either<Failure, SendOtpModel>> sendOtp(SendOtpModel model) async {
    try {
      final data = await _loginRemoteDataSource.sendOtp(model);
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserData>> verifyOtp(VerifyOtpModel model) async {
    try {
      final data = await _loginRemoteDataSource.verifyOtp(model);
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }
}
