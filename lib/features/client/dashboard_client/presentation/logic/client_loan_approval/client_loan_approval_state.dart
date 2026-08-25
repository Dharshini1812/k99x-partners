// lib/features/client/presentation/logic/loan_approve_state.dart

import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_loan_approval_state.freezed.dart';

@freezed
class LoanApproveState with _$LoanApproveState {
  const factory LoanApproveState.initial() = _LoanApproveInitial;
  const factory LoanApproveState.loading() = _LoanApproveLoading;
  const factory LoanApproveState.data(LoanApproveResponseModel data) =
      _LoanApproveData;
  const factory LoanApproveState.error(String msg) = _LoanApproveError;
}
