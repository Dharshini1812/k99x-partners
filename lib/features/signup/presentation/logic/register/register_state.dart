// lib/features/signup/presentation/logic/register_state.dart
//
// Same shape as your SendOtpState — initial/loading/data/error.

import 'package:dealer/features/signup/data/model/register_result_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = _RegisterStateInitial;
  const factory RegisterState.loading() = _RegisterStateLoading;
  const factory RegisterState.data(RegisterResponse data) = _RegisterStateData;
  const factory RegisterState.error(String msg) = _RegisterStateError;
}
