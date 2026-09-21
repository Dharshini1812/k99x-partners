// lib/features/signup/data/repository/register_repository_impl.dart
//
// Thin on purpose right now — its job is the DI/testing seam between the
// domain layer and the datasource. This is also the natural place to add
// response mapping, local caching, or retry logic later without touching
// the usecase or notifier.

import 'package:dealer/features/signup/data/datasource/datasource.dart';
import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/data/model/register_result_model.dart';
import 'package:dealer/features/signup/domain/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterDataSource dataSource;
  RegisterRepositoryImpl(this.dataSource);

  @override
  Future<RegisterResponse> register(RegisterRequestModel request) {
    return dataSource.register(request);
  }
}

final registerRepositoryProvider = Provider<RegisterRepository>(
  (ref) => RegisterRepositoryImpl(ref.watch(registerDataSourceProvider)),
);
