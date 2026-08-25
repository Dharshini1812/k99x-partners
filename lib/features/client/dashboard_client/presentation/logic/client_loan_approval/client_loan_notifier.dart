// lib/features/client/presentation/logic/loan_approve_notifier.dart

import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:dealer/features/client/dashboard_client/domain/usecase/client_loan_approval.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/client_loan_approval/client_loan_approval_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoanApproveNotifier extends StateNotifier<LoanApproveState> {
  final ApproveLoan _usecase;

  LoanApproveNotifier({required ApproveLoan usecase})
      : _usecase = usecase,
        super(const LoanApproveState.initial());

  /// Returns the response on success (null on failure) so the caller can
  /// gate UI (e.g. showing a success snackbar, refreshing the stock
  /// list) on whether it actually worked.
  Future<LoanApproveResponseModel?> approve(
      LoanApproveRequestModel request) async {
    state = const LoanApproveState.loading();

    final result = await _usecase(request);

    return result.fold(
      (failure) {
        state = LoanApproveState.error(failure.msg ?? 'Loan approval failed');
        return null;
      },
      (response) {
        state = LoanApproveState.data(response);
        return response;
      },
    );
  }
}
