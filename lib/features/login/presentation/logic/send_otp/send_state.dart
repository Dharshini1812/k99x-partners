import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_state.freezed.dart';

@freezed
class SendOtpState with _$SendOtpState {
  const factory SendOtpState.initial() = _SendOtpStateInitial;
  const factory SendOtpState.loading() = _SendOtpStateLoading;
  const factory SendOtpState.data(SendOtpModel data) = _SendOtpStateData;
  const factory SendOtpState.error(String msg) = _SendOtpStateError;
}
