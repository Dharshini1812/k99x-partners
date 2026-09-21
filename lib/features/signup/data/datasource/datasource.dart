// lib/features/signup/data/datasource/register_datasource.dart
import 'package:dealer/core/services/api_service.dart';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/data/model/register_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class RegisterDataSource {
  Future<RegisterResponse> register(RegisterRequestModel request);
}

class RegisterDataSourceImpl implements RegisterDataSource {
  final ApiService apiService;
  RegisterDataSourceImpl(this.apiService);

  @override
  Future<RegisterResponse> register(RegisterRequestModel request) async {
    final formData = await request.toFormData();

    // Registration happens before there's a session, so this call
    // shouldn't attach the Basic Auth header — your postMultipart already
    // supports that via requiresAuth.
    final response = await apiService.postMultipart(
      Url.registerUrl,
      formData,
      requiresAuth: false,
    );

    final json = Map<String, dynamic>.from(response.data as Map);
    return RegisterResponse.fromJson(json);
  }
}

final registerDataSourceProvider = Provider<RegisterDataSource>(
  (ref) => RegisterDataSourceImpl(ref.watch(apiServiceProvider)),
);
