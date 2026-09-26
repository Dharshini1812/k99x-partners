import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/domain/usecase/send_otp.dart';
import 'package:dealer/features/login/presentation/logic/send_otp/send_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendOtpNotifier extends StateNotifier<SendOtpState> {
  // final Ref ref;
  final SendOtpUsecase _usecase;

  SendOtpNotifier({
    required SendOtpUsecase usecase,
    SendOtpState? initialState,
  })  : _usecase = usecase,
        super(initialState ?? const SendOtpState.initial());

// Inside send_notifier.dart
  Future<SendOtpModel?> sendOtp(SendOtpModel params) async {
    state = const SendOtpState.loading();
    try {
      final result = await _usecase(params);

      return result.fold(
        (failure) {
          state = SendOtpState.error(failure.msg ?? failure.toString());
          return null;
        },
        (data) {
          state = SendOtpState.data(data);
          return data; // Return the response data
        },
      );
    } catch (e) {
      state = SendOtpState.error(e.toString());
      return null;
    }
  }
}
