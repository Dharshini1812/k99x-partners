// lib/features/login/domain/usecase/logout.dart

import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/login/data/model/logout_model.dart';
import 'package:dealer/features/login/domain/repository/repository.dart'; // ADAPT

class Logout {
  final LoginRepository repository;
  Logout(this.repository);

  Future<Either<Failure, LogoutResponseModel>> call() {
    return repository.logout();
  }
}
