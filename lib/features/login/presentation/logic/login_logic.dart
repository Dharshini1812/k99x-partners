import 'dart:async';
import 'package:dealer/features/login/data/model/send_otp.dart';
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

  // guards against double-fire (double tap, duplicate sms_autofill events, etc.)
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String? _lastVerifiedOtp;

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
  }

  void onOtpDigit(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // ── Handle multi-digit paste (e.g., pasting "1234") ─────────
    if (digits.length > 1) {
      for (int i = 0; i < 4; i++) {
        if (i < digits.length) {
          otpCtrlList[i].text = digits[i];
        } else {
          otpCtrlList[i].clear();
        }
      }

      // Move focus to the last filled box or unfocus if all 4 are filled
      if (digits.length >= 4) {
        otpFocusList[3].unfocus();
      } else {
        otpFocusList[digits.length].requestFocus();
      }

      notifyListeners();
      return;
    }

    // ── Handle single digit input ────────────────────────────────
    if (digits.isNotEmpty) {
      otpCtrlList[index].text = digits;
      if (index < 3) {
        otpFocusList[index + 1].requestFocus();
      } else {
        otpFocusList[index].unfocus();
      }
    } else {
      otpCtrlList[index].clear();
    }

    notifyListeners();
  }

  void onBackspace(int index) {
    if (index > 0) {
      otpFocusList[index - 1].requestFocus();
      otpCtrlList[index - 1].clear();
    }
  }

  Future<void> sendOtp(SendOtpModel sendModel) async {
    if (_isSendingOtp) return; // block double tap / re-entry

    _isSendingOtp = true;
    try {
      // build model using the trimmed value passed in
      await ref.read(sendOtpProvider.notifier).sendOtp(sendModel);
    } finally {
      _isSendingOtp = false;
    }
  }

  Future<void> verifyOtp() async {
    if (_isVerifyingOtp) return; // block concurrent/duplicate calls
    if (fullOtp.length < 4) return;
    if (_lastVerifiedOtp == fullOtp) {
      return; // block duplicate sms_autofill fires
    }

    _isVerifyingOtp = true;
    _lastVerifiedOtp = fullOtp;

    for (final f in otpFocusList) {
      f.unfocus();
    }

    try {
      final params = VerifyOtpModel(
        phone: phoneCtrl.text.trim(),
        otp: fullOtp,
        isRegistered: true,
        role: 'DEALER',
        source: 2,
      );
      await ref.read(verifyOtpProvider.notifier).verifyOtp(params);
    } finally {
      _isVerifyingOtp = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendSeconds > 0) return;

    for (final c in otpCtrlList) {
      c.clear();
    }
    _lastVerifiedOtp = null; // allow a fresh code to be verified

    // actually re-request a code — this was missing before
    await sendOtp(SendOtpModel(phone: phoneCtrl.text.trim()));

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

  void setAutoOtp(String otp) {
    if (otp.length != 4) return;

    for (int i = 0; i < otpCtrlList.length; i++) {
      otpCtrlList[i].text = otp[i];
    }

    isOtpValid = true;
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
}
