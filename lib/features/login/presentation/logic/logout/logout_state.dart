// lib/features/login/presentation/logic/logout_state.dart
import 'package:dealer/features/login/data/model/logout_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_state.freezed.dart';

@freezed
class LogoutState with _$LogoutState {
  const factory LogoutState.initial() = _LogoutInitial;
  const factory LogoutState.loading() = _LogoutLoading;
  const factory LogoutState.data(LogoutResponseModel data) = _LogoutData;
  const factory LogoutState.error(String msg) = _LogoutError;
}
