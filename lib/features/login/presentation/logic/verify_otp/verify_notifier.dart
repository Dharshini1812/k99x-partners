import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/domain/usecase/verify_otp.dart';
import 'package:dealer/features/login/presentation/logic/verify_otp/verify_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtpNotifier extends StateNotifier<VerifyOtpState> {
  // final Ref ref;
  final VerifyOtpUsecase _usecase;

  VerifyOtpNotifier({
    required VerifyOtpUsecase usecase,
    VerifyOtpState? initialState,
  })  : _usecase = usecase,
        super(initialState ?? const VerifyOtpState.initial());

  Future<void> verifyOtp(VerifyOtpModel params) async {
    state = const VerifyOtpState.loading();
    final result = await _usecase(params);
    result.fold(
      (l) => state = VerifyOtpState.error(l.msg ?? 'An error occurred'),
      (r) => state = VerifyOtpState.data(r),
    );
  }
}
