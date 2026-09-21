// lib/features/signup/domain/repository/register_repository.dart

import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/data/model/register_result_model.dart';

abstract class RegisterRepository {
  Future<RegisterResponse> register(RegisterRequestModel request);
}
