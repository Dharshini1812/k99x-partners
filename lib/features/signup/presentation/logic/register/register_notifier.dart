// lib/features/signup/presentation/logic/register_notifier.dart

import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/domain/usecase/reg_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'register_state.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final RegisterUseCase useCase;
  RegisterNotifier(this.useCase) : super(const RegisterState.initial());

  Future<void> register(RegisterRequestModel request) async {
    state = const RegisterState.loading();
    try {
      final result = await useCase.call(request);
      state = result.success
          ? RegisterState.data(result)
          : RegisterState.error(result.message);
    } on DioException catch (e) {
      state = RegisterState.error(_dioErrorMessage(e));
    } catch (e) {
      state = RegisterState.error(e.toString());
    }
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(ref.watch(registerUseCaseProvider)),
);
