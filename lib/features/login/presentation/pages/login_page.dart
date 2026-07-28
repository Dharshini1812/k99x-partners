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
    ref.read(loginLogicProvider).disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(loginLogicProvider);
    final state = ref.watch(sendOtpProvider);

    // ── Navigate to loader → OTP after OTP is sent ──────────────────────
    // ref.listen(authProvider, (prev, next) {
    //   if (prev?.status != AuthStatus.otpSent &&
    //       next.status == AuthStatus.otpSent) {
    //     Navigator.pushNamed(context, '/auth-loader');
    //   }
    // });
    ref.listen(sendOtpProvider, (previous, next) {
      next.whenOrNull(
        data: (data) {
          // Fluttertoast.showToast(
          //   msg: 'OTP sent successfully',
          //   toastLength: Toast.LENGTH_SHORT,
          // );
          ref.read(loginPhoneProvider.notifier).state =
              logic.phoneCtrl.text.trim();
          ref.read(routeService).push(const OtpRoute(), context);
          // Navigator.pushNamed(context, '/auth-loader');
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
        role: 'VALUATOR',
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
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),

                        // ── Shield icon ─────────────────────────────────────────────
                        // const Center(child: ShieldIcon()),

                        const SizedBox(height: 20),

                        // ── Title ───────────────────────────────────────────────────
                        const Center(
                          child: Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Subtitle ────────────────────────────────────────────────
                        const Center(
                          child: Text(
                            'Log in with OTP to upload Vehicles',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textGrey,
                              height: 1.55,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Phone number label ──────────────────────────────────────
                        const Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Phone input ─────────────────────────────────────────────
                        _PhoneField(
                          controller: logic.phoneCtrl,
                          focusNode: logic.phoneFocus,
                        ),

                        const SizedBox(height: 24),

                        // ── Send OTP button ─────────────────────────────────────────
                        _PrimaryButton(
                          label: 'Send OTP',
                          isLoading: state.maybeWhen(
                            loading: () => true,
                            orElse: () => false,
                          ),
                          isEnabled: logic.isPhoneValid,
                          onTap: () => sendOtp(),
                          // onTap: () => logic.sendOtp(
                          //   context,
                          //   SendOtpModel(
                          //     phone: logic.phoneCtrl.text,
                          //     isRegistered: true,
                          //   ),
                          // ),
                        ),

                        const SizedBox(height: 24),
                        const Spacer()
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Country code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
            ),
            child: const Text(
              '+91',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xff064f86),
              ),
            ),
          ),

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
                letterSpacing: 2,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter your phone number',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B5C0),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          color: isEnabled ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
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
