// lib/features/login/presentation/pages/login_page.dart

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final logic = ref.read(loginLogicProvider);
      logic.init();
      logic.clearOtpState(keepPhone: true);
    });
  }

  /// Sends the OTP to the entered phone number. An inactive account is
  /// NOT a reason to strand the person on this screen — they still get
  /// to verify who they are on the OTP page; whatever "inactive" gates
  /// (dashboard access, etc.) is enforced after that, not here. This
  /// deliberately checks for "inactive" in BOTH places the backend could
  /// surface it — a normal {success:false, message:"..."} response, or a
  /// thrown error — since which one actually happens isn't visible from
  /// this file alone (that's inside sendOtpProvider's notifier/datasource).
  Future<void> _handleSendOtp() async {
    final logic = ref.read(loginLogicProvider);
    final phone = logic.phoneCtrl.text.trim();
    if (phone.length < 10) return;

    logic.phoneFocus.unfocus();
    setState(() => _isLoading = true);

    final sendNotifier = ref.read(sendOtpProvider.notifier);

    try {
      final response = await sendNotifier.sendOtp(SendOtpModel(
        phone: phone,
        isRegistered: true,
      ));

      if (!mounted) return;

      // A null response means sendOtp() itself couldn't produce a real
      // result (network failure, unparseable body) — there's genuinely
      // nothing to send them to an OTP screen for.
      if (response == null) {
        Fluttertoast.showToast(msg: 'Something went wrong. Please try again.');
        return;
      }

      final message = response.message ?? '';
      // .contains(), not == — the previous exact-match check had an
      // extra stray character baked into the literal, so it could never
      // actually match a real backend message.
      final isInactive = message.toLowerCase().contains('inactive');

      if (isInactive) {
        Fluttertoast.showToast(
          msg: message.isNotEmpty
              ? message
              : 'Your account is inactive. Please contact administrator',
        );
        return;
      } else if (response.success == false) {
        Fluttertoast.showToast(
            msg: message.isNotEmpty ? message : 'Failed to send OTP');
      }

      final bool isUserRegistered = response.success == true &&
          !message.toLowerCase().contains('user not found');

      ref.read(loginPhoneProvider.notifier).state = phone;
      ref.read(loginIsRegisteredProvider.notifier).state = isUserRegistered;

      // Reached for every case above except the null-response early
      // return — including isInactive — so an inactive account still
      // lands on the OTP page, just with the warning toast already shown.
      ref.read(routeService).push(const OtpRoute(), context);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();

      if (message.toLowerCase().contains('inactive')) {
        // Some deployments surface "account inactive" as a thrown error
        // instead of a normal {success:false} response — same rule
        // applies: still send them to the OTP page, don't strand them
        // here just because this came back as an exception instead.
        Fluttertoast.showToast(msg: message);
        ref.read(loginPhoneProvider.notifier).state = phone;
        // Assumes inactive implies a real, existing (just deactivated)
        // account — flag this if that's not actually true server-side.
        ref.read(loginIsRegisteredProvider.notifier).state = true;
        ref.read(routeService).push(const OtpRoute(), context);
      } else {
        Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(loginLogicProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
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
                  style: TextStyle(fontSize: 16, color: _kGrey, height: 1.5),
                ),
                const SizedBox(height: 36),
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
                _PhoneField(
                  controller: logic.phoneCtrl,
                  focusNode: logic.phoneFocus,
                ),
                const SizedBox(height: 28),
                _PrimaryButton(
                  label: 'Send OTP',
                  isLoading: _isLoading,
                  isEnabled: logic.isPhoneValid,
                  onTap: _handleSendOtp,
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "We'll text a one-time code to\nverify it's you",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _kGrey,
                      height: 1.5,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kDark,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1.5, height: 24, color: _kBorder),
          const SizedBox(width: 12),
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
                fontSize: 17,
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
