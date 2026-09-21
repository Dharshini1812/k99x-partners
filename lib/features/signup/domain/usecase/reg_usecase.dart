// lib/features/signup/domain/usecase/register_usecase.dart

import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/data/model/register_result_model.dart';
import 'package:dealer/features/signup/data/repoistory/repository_impl.dart';
import 'package:dealer/features/signup/domain/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUseCase {
  final RegisterRepository repository;
  RegisterUseCase(this.repository);

  Future<RegisterResponse> call(RegisterRequestModel request) {
    return repository.register(request);
  }
}

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(registerRepositoryProvider)),
);
