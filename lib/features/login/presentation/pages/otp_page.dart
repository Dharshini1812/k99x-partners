import 'dart:async';
import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/login/presentation/logic/login_logic.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autofill/sms_autofill.dart';

// ── Palette — shared with the login page ────────────────────────────────────
const _kLogoBlue = Color(0xFF1E2FE0);
const _kAccentBlue = Color(0xFF3B4EF5);
const _kDark = Color(0xFF11142A);
const _kGrey = Color(0xFF8B8FA3);
const _kFaintBg = Color(0xFFEDEFF7);
const _kBoxBorder = Color(0xFFE3E5F2);
const _kDisabledBg = Color(0xFFE3E6F7);

@AutoRoute()
class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> with CodeAutoFill {
  @override
  void initState() {
    super.initState();
    // Auto-focus first box
    Future.microtask(() {
      ref.read(loginLogicProvider).initOtp();
    });

    listenForCode();
  }

  @override
  void codeUpdated() {
    final otp = code ?? '';

    if (otp.length == 4) {
      ref.read(loginLogicProvider).setAutoOtp(otp);
      ref.read(loginLogicProvider).verifyOtp();
    }
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyOtpProvider);
    final logic = ref.watch(loginLogicProvider);
    final phone = ref.watch(loginPhoneProvider);

    // Navigate after successful verification
    ref.listen(verifyOtpProvider, (previous, next) {
      next.whenOrNull(
        data: (data) {
          log('success');
          ref.read(routeService).push(const BottomNavRoute(), context);
        },
        error: (msg) {
          // show toast here if needed
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Header row: back button + logo badge ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: _kFaintBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          size: 26, color: _kAccentBlue),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: _kLogoBlue,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'images/logo/small-logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Title ───────────────────────────────────────────────────
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Enter the 4-digit code sent to',
                style: TextStyle(
                  fontSize: 15,
                  color: _kGrey,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Text(
                    '+91 $phone',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _kDark,
                    ),
                  ),
                  const Text(
                    '  ·  ',
                    style: TextStyle(fontSize: 15.5, color: _kGrey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: _kAccentBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ── 4 OTP boxes ─────────────────────────────────────────────
              Row(
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    Expanded(
                      child: _OtpBox(
                        controller: logic.otpCtrlList[i],
                        focusNode: logic.otpFocusList[i],
                        onChanged: (v) => logic.onOtpDigit(i, v),
                        onBackspace: () => logic.onBackspace(i),
                      ),
                    ),
                    if (i < 3) const SizedBox(width: 16),
                  ],
                ],
              ),

              const SizedBox(height: 28),

              // ── Resend ──────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: logic.resendOtp,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: _kGrey),
                      children: [
                        const TextSpan(text: "Didn't get it? "),
                        TextSpan(
                          text: logic.resendSeconds > 0
                              ? 'Resend OTP in ${logic.resendSeconds}s'
                              : 'Resend OTP',
                          style: TextStyle(
                            color:
                                logic.resendSeconds > 0 ? _kGrey : _kAccentBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Verify button ───────────────────────────────────────────
              _VerifyButton(
                isLoading: state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                ),
                isEnabled: logic.isOtpValid,
                onTap: logic.verifyOtp,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (_, child) {
        final isFocused = focusNode.hasFocus;

        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: _kFaintBg.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocused ? _kAccentBlue : _kBoxBorder,
              width: isFocused ? 2 : 1.5,
            ),
          ),
          child: child,
        );
      },
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _kDark,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onTap;

  const _VerifyButton(
      {required this.isLoading, required this.isEnabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (!isLoading && isEnabled) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isEnabled ? _kAccentBlue : _kDisabledBg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: _kAccentBlue.withOpacity(0.35),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: isEnabled ? Colors.white : Colors.white70,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Verify & Continue',
                  style: TextStyle(
                    color: isEnabled
                        ? Colors.white
                        : Colors.white.withOpacity(0.85),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
