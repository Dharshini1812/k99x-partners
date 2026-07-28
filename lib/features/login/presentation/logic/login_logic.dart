import 'dart:async';
import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginLogicProvider =
    ChangeNotifierProvider.autoDispose<LoginLogic>((ref) => LoginLogic(ref));

class LoginLogic extends ChangeNotifier {
  final Ref ref;
  LoginLogic(this.ref);

  final phoneCtrl = TextEditingController();
  final phoneFocus = FocusNode();
  final List<TextEditingController> otpCtrlList =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> otpFocusList = List.generate(4, (_) => FocusNode());

  int resendSeconds = 30;
  Timer? resendTimer;
  bool isOtpValid = false;
  bool isPhoneValid = false;
  String get fullOtp => otpCtrlList.map((c) => c.text).join();
  void init() {
    phoneCtrl.removeListener(_validatePhone);
    phoneCtrl.addListener(_validatePhone);
  }

  void _validatePhone() {
    isPhoneValid = phoneCtrl.text.trim().length == 10;
    notifyListeners();
  }

  void _validateOtp() {
    isOtpValid = fullOtp.length == 4;
    notifyListeners();
  }

  void initOtp() {
    startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpFocusList[0].requestFocus();
    });

    for (final controller in otpCtrlList) {
      controller.removeListener(_validateOtp);
      controller.addListener(_validateOtp);
    }
    // Future.delayed(const Duration(seconds: 1), () {
    //   setAutoOtp('1234');
    //   verifyOtp();
    // });
  }

  void onOtpDigit(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      otpFocusList[index + 1].requestFocus();
    }
  }

  void onBackspace(int index) {
    if (index > 0) {
      otpFocusList[index - 1].requestFocus();
      otpCtrlList[index - 1].clear();
    }
  }

  // }
  Future<void> verifyOtp() async {
    if (fullOtp.length < 4) return;

    for (final f in otpFocusList) {
      f.unfocus();
    }

    final params = VerifyOtpModel(
      phone: phoneCtrl.text.trim(),
      otp: fullOtp,
      isRegistered: true,
      role: 'VALUATOR',
      source: 2,
    );

    await ref.read(verifyOtpProvider.notifier).verifyOtp(params);
  }

  Future<void> resendOtp() async {
    if (resendSeconds > 0) return;

    for (final c in otpCtrlList) {
      c.clear();
    }

    startResendTimer();
  }

  void startResendTimer() {
    resendSeconds = 30;
    resendTimer?.cancel();

    resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (resendSeconds > 0) {
        resendSeconds--;
        notifyListeners();
      } else {
        resendTimer?.cancel();
      }
    });

    notifyListeners();
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    phoneFocus.dispose();

    for (final c in otpCtrlList) {
      c.dispose();
    }

    for (final f in otpFocusList) {
      f.dispose();
    }

    resendTimer?.cancel();

    super.dispose();
  }

  void setAutoOtp(String otp) {
    if (otp.length != 4) return;

    for (int i = 0; i < otpCtrlList.length; i++) {
      otpCtrlList[i].text = otp[i];
    }

    isOtpValid = true;
    notifyListeners();
  }

  void disposeControllers() {
    phoneCtrl.dispose();
    phoneFocus.dispose();
  }
}
