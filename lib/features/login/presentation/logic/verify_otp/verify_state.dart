import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_state.freezed.dart';

@freezed
class VerifyOtpState with _$VerifyOtpState {
  const factory VerifyOtpState.initial() = _VerifyOtpStateInitial;
  const factory VerifyOtpState.loading() = _VerifyOtpStateLoading;
  const factory VerifyOtpState.data(UserData data) = _VerifyOtpStateData;
  const factory VerifyOtpState.error(String msg) = _VerifyOtpStateError;
}
