import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/presentation/logic/login_logic.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ── Palette pulled from the splash / brand screens ──────────────────────────
const _kAccentBlue = Color(0xFF3B4EF5);
const _kDark = Color(0xFF11142A);
const _kGrey = Color(0xFF8B8FA3);
const _kFaintBg = Color(0xFFEDEFF7);
const _kBorder = Color(0xFFE7E8F0);

@AutoRoute()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(loginLogicProvider).init();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(loginLogicProvider);
    final state = ref.watch(sendOtpProvider);

    ref.listen(sendOtpProvider, (previous, next) {
      next.whenOrNull(
        data: (data) {
          ref.read(loginPhoneProvider.notifier).state =
              logic.phoneCtrl.text.trim();
          ref.read(routeService).push(const OtpRoute(), context);
        },
        error: (msg) {
          Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_SHORT,
          );
        },
      );
    });

    Future<void> sendOtp() async {
      final phone = logic.phoneCtrl.text.trim();
      if (phone.length < 10) return;

      logic.phoneFocus.unfocus();
      final data = SendOtpModel(
        phone: logic.phoneCtrl.text,
        isRegistered: true,
        role: 'DEALER',
        source: 2,
      );
      await ref.read(sendOtpProvider.notifier).sendOtp(data);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),

                        // ── Logo lockup ─────────────────────────────────
                        Center(
                          child: Image.asset(
                            'images/logo/large-logo.png',
                            width: MediaQuery.of(context).size.width * 0.6,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Center(
                          child: Text(
                            'PARTNER STOCKS',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                              color: _kGrey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ── Headline ────────────────────────────────────
                        const Text(
                          'Upload it. Compare it.\nSell it faster.',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: _kDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Sign in to manage your dealership's stock from one place.",
                          style: TextStyle(
                            fontSize: 18,
                            color: _kGrey,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Phone number label ──────────────────────────
                        const Text(
                          'MOBILE NUMBER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: _kGrey,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Phone input ──────────────────────────────────
                        _PhoneField(
                          controller: logic.phoneCtrl,
                          focusNode: logic.phoneFocus,
                        ),

                        const SizedBox(height: 28),

                        // ── Send OTP button ──────────────────────────────
                        _PrimaryButton(
                          label: 'Send OTP',
                          isLoading: state.maybeWhen(
                            loading: () => true,
                            orElse: () => false,
                          ),
                          isEnabled: logic.isPhoneValid,
                          onTap: () => sendOtp(),
                        ),

                        const SizedBox(height: 16),

                        const Center(
                          child: Text(
                            "We'll text a one-time code to\nverify it's you",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: _kGrey,
                              height: 1.5,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone field — pill shaped, icon avatar + code + input
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _PhoneField({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _kFaintBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_rounded,
              size: 18,
              color: _kAccentBlue,
            ),
          ),

          const SizedBox(width: 12),

          // Country code
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kDark,
            ),
          ),

          const SizedBox(width: 12),

          Container(width: 1.5, height: 24, color: _kBorder),

          const SizedBox(width: 12),

          // Number input
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                letterSpacing: 1.5,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _kDark,
              ),
              decoration: const InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  color: Color(0xFFC3C6D4),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary button
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isEnabled;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (!isLoading && isEnabled) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isEnabled ? _kAccentBlue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
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
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
