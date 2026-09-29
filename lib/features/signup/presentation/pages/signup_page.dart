import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/presentation/logic/login_logic.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/presentation/logic/register/register_notifier.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../data/model/onboarding_model.dart';
import '../logic/signup_logic.dart';
import '../widgets/upload_tile.dart';
import '../widgets/section_wrapper.dart';

const _kAccentBlue = Color(0xFF3B4EF5);
const _kDark = Color(0xFF11142A);
const _kGrey = Color(0xFF8B8FA3);
const _kFaintBg = Color(0xFFEDEFF7);
const _kBorder = Color(0xFFE7E8F0);
const _kGreen = Color(0xFF1CB098);

@AutoRoute()
class SignupPage extends ConsumerStatefulWidget {
  final String? prefilledMobile;
  const SignupPage({super.key, this.prefilledMobile});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.prefilledMobile != null &&
        widget.prefilledMobile!.trim().isNotEmpty) {
      ref.read(signUpLogicProvider).phoneCtrl.text =
          widget.prefilledMobile!.trim();
    }
  }

  Future<File?> _pickImage({required bool cameraOnly}) async {
    if (cameraOnly) {
      final x =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      return x == null ? null : File(x.path);
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    final x = await _picker.pickImage(source: source, imageQuality: 85);
    return x == null ? null : File(x.path);
  }

  Future<void> _pickReceipt(SignUpLogic logic) async {
    final file = await _pickImage(cameraOnly: false);
    if (file != null) setState(() => logic.paymentReceipt = file);
  }

  Future<void> _pickDoc(SignUpLogic logic, void Function(File) assign) async {
    final file = await _pickImage(cameraOnly: false);
    if (file == null) return;
    setState(() => assign(file));
    if (logic.images.aadhaarFront != null && logic.images.panCard != null) {
      ref.read(nameMatchStatusProvider.notifier).state =
          NameMatchStatus.checking;
      final status = await logic.checkNameMatch();
      ref.read(nameMatchStatusProvider.notifier).state = status;
    }
  }

  Future<void> _startFreeTrial() async {
    final trial = ref.read(trialLogic);
    if (trial.everUsedTrial) {
      Fluttertoast.showToast(
        msg: trial.isTrialActive
            ? 'Your free trial is already running on this device.'
            : 'You\'ve already used your free trial on this device — please sign up below to continue.',
      );
      return;
    }
    final started = await trial.startTrial();
    if (!started || !mounted) return;
    ref.read(routeService).pushAndRemoveUntil(const BottomNavRoute(), context);
  }

  void _goNext(int currentIndex, bool valid) {
    if (!valid) {
      Fluttertoast.showToast(msg: 'Please complete this section first');
      return;
    }
    final completed = [...ref.read(sectionCompleteProvider)];
    completed[currentIndex] = true;
    ref.read(sectionCompleteProvider.notifier).state = completed;
    final next = currentIndex + 1;
    ref.read(expandedSectionProvider.notifier).state = next < 3 ? next : -1;
  }

  Future<void> _submitRegistration(SignUpLogic logic) async {
    if (!logic.isBusinessInfoValid ||
        !logic.isPersonalDocsValid ||
        !logic.isSecurityDepositValid) {
      Fluttertoast.showToast(msg: 'Please complete every section first');
      return;
    }

    await ref.read(registerProvider.notifier).register(
          RegisterRequestModel(
            firstName: logic.firstNameCtrl.text.trim(),
            lastName: logic.lastNameCtrl.text.trim(),
            phoneNumber: logic.phoneCtrl.text.trim(),
            email: logic.emailCtrl.text.trim(),
            state: logic.selectedStateId!,
            city: logic.selectedCityId!,
            pincode: logic.pincodeCtrl.text.trim(),
            aadhaarFrontCardPath: logic.images.aadhaarFront!.path,
            aadhaarBackCardPath: logic.images.aadhaarBack!.path,
            pancardPath: logic.images.panCard!.path,
            paymentReceiptPath: logic.paymentReceipt!.path,
            paymentMethod: 'UPI',
            amount: SignUpLogic.depositAmount,
            referenceId: logic.referenceIdCtrl.text.trim(),
            password: logic.passwordCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.watch(signUpLogicProvider);
    final expanded = ref.watch(expandedSectionProvider);
    final completed = ref.watch(sectionCompleteProvider);
    final nameMatch = ref.watch(nameMatchStatusProvider);
    final registerState = ref.watch(registerProvider);
    final isSubmitting =
        registerState.maybeWhen(loading: () => true, orElse: () => false);

    ref.listen(registerProvider, (previous, next) {
      next.whenOrNull(
        data: (data) {
          Fluttertoast.showToast(msg: data.message);
          final registeredPhone = logic.phoneCtrl.text.trim();

          ref.read(loginLogicProvider).clearOtpState(keepPhone: true);
          ref.read(loginPhoneProvider.notifier).state = registeredPhone;
          ref.read(loginLogicProvider).phoneCtrl.text = registeredPhone;
          ref.read(loginIsRegisteredProvider.notifier).state = true;
          ref
              .read(routeService)
              .pushAndRemoveUntil(const LoginRoute(), context);
        },
        error: (msg) =>
            Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: _startFreeTrial,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A3DE8), Color(0xFF9B4DE0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Explore app via free trial ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    OnboardingSection(
                      stepNumber: 1,
                      totalSteps: 3,
                      title: 'Business Information',
                      isExpanded: expanded == 0,
                      isCompleted: completed[0],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 0 ? -1 : 0,
                      child: _BusinessInfoForm(
                        logic: logic,
                        initiallyVerified: widget.prefilledMobile != null &&
                            widget.prefilledMobile!.trim().isNotEmpty,
                        onNext: () => _goNext(0, logic.isBusinessInfoValid),
                      ),
                    ),
                    OnboardingSection(
                      stepNumber: 2,
                      totalSteps: 3,
                      title: 'Personal documents',
                      isExpanded: expanded == 1,
                      isCompleted: completed[1],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 1 ? -1 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keep registered mobile number handy for OTP verification',
                            style: TextStyle(fontSize: 13, color: _kGrey),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UploadTile(
                                  label: 'Aadhar front photo',
                                  required: true,
                                  icon: Icons.upload_file_outlined,
                                  actionText: 'Upload Aadhar front',
                                  file: logic.images.aadhaarFront,
                                  onTap: () => _pickDoc(logic,
                                      (f) => logic.images.aadhaarFront = f),
                                  onRetake: () => _pickDoc(logic,
                                      (f) => logic.images.aadhaarFront = f),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: UploadTile(
                                  label: 'Aadhar back photo',
                                  required: true,
                                  icon: Icons.upload_file_outlined,
                                  actionText: 'Upload Aadhar back',
                                  file: logic.images.aadhaarBack,
                                  onTap: () => _pickDoc(logic,
                                      (f) => logic.images.aadhaarBack = f),
                                  onRetake: () => _pickDoc(logic,
                                      (f) => logic.images.aadhaarBack = f),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.42,
                            child: UploadTile(
                              label: 'PAN photo',
                              required: true,
                              icon: Icons.upload_file_outlined,
                              actionText: 'Upload PAN card',
                              file: logic.images.panCard,
                              onTap: () => _pickDoc(
                                  logic, (f) => logic.images.panCard = f),
                              onRetake: () => _pickDoc(
                                  logic, (f) => logic.images.panCard = f),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _NameMatchBanner(status: nameMatch, logic: logic),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.error_outline,
                                  size: 15, color: Color(0xFFE0A000)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Name on ID & PAN card should be identical',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFFE0A000)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _NextButton(
                            enabled: logic.isPersonalDocsValid,
                            onTap: () => _goNext(1, logic.isPersonalDocsValid),
                          ),
                        ],
                      ),
                    ),
                    OnboardingSection(
                      stepNumber: 3,
                      totalSteps: 3,
                      title: 'Security Deposit',
                      isExpanded: expanded == 2,
                      isCompleted: completed[2],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 2 ? -1 : 2,
                      child: _SecurityDepositSection(
                        logic: logic,
                        isSubmitting: isSubmitting,
                        onPickReceipt: () => _pickReceipt(logic),
                        onSubmit: () => _submitRegistration(logic),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => ref
                            .read(routeService)
                            .push(const LoginRoute(), context),
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(
                              color: _kAccentBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessInfoForm extends ConsumerStatefulWidget {
  final SignUpLogic logic;
  final VoidCallback onNext;
  final bool initiallyVerified;

  const _BusinessInfoForm({
    required this.logic,
    required this.onNext,
    this.initiallyVerified = false,
  });

  @override
  ConsumerState<_BusinessInfoForm> createState() => _BusinessInfoFormState();
}

class _BusinessInfoFormState extends ConsumerState<_BusinessInfoForm> {
  bool _pending = true;
  late bool _isPhoneVerified;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _isPhoneVerified = widget.initiallyVerified;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(getStateProvider.notifier).getState();
        if (widget.logic.selectedStateId != null) {
          _fetchCities(widget.logic.selectedStateId!);
        }
      }
    });
  }

  void _fetchCities(String stateId) {
    try {
      (ref.read(getCityProvider.notifier) as dynamic).getCity(id: stateId);
    } catch (_) {
      try {
        (ref.read(getCityProvider.notifier) as dynamic).getCity(stateId);
      } catch (e) {
        debugPrint('Error fetching cities: $e');
      }
    }
  }

  void _maybeAutoAdvance() {
    final isValid = widget.logic.isBusinessInfoValid && _isPhoneVerified;
    if (isValid && _pending) {
      _pending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onNext();
      });
    } else if (!isValid) {
      _pending = true;
    }
  }

  Future<void> _handleSendOtp() async {
    final phone = widget.logic.phoneCtrl.text.trim();
    if (phone.length != 10) {
      Fluttertoast.showToast(
          msg: 'Please enter a valid 10-digit mobile number');
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(sendOtpProvider.notifier)
        .sendOtp(SendOtpModel(phone: phone));

    if (!mounted) return;

    final sendOtpState = ref.read(sendOtpProvider);
    sendOtpState.whenOrNull(
      data: (res) {
        Fluttertoast.showToast(msg: 'OTP sent successfully');
        _openOtpSheet(phone);
      },
      error: (msg) => Fluttertoast.showToast(msg: msg),
    );
  }

  void _openOtpSheet(String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _OtpVerificationSheet(
        phone: phone,
        onVerified: () {
          setState(() {
            _isPhoneVerified = true;
          });
          Fluttertoast.showToast(msg: 'Mobile number verified successfully!');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;
    _maybeAutoAdvance();

    final isPhoneComplete = logic.phoneCtrl.text.trim().length == 10;
    final isSendingOtp = ref.watch(sendOtpProvider).maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

    return Column(
      children: [
        _RoundedField(
          controller: logic.firstNameCtrl,
          hint: 'First Name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.lastNameCtrl,
          hint: 'Last Name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.emailCtrl,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.passwordCtrl,
          hint: 'Password',
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: _kGrey,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'At least 8 characters, with a letter and a number',
            style: TextStyle(
              fontSize: 11.5,
              color: logic.passwordCtrl.text.isEmpty
                  ? _kGrey
                  : (logic.isPasswordValid
                      ? const Color(0xFF1FAA59)
                      : const Color(0xFFD64545)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.confirmPasswordCtrl,
          hint: 'Confirm password',
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: _kGrey,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        if (logic.confirmPasswordCtrl.text.isNotEmpty &&
            !logic.passwordsMatch) ...[
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "Passwords don't match",
              style: TextStyle(fontSize: 11.5, color: Color(0xFFD64545)),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _PhoneField(
          controller: logic.phoneCtrl,
          focusNode: logic.phoneFocus,
          enabled: !_isPhoneVerified,
          onChanged: (val) {
            if (_isPhoneVerified) {
              setState(() => _isPhoneVerified = false);
            } else {
              setState(() {});
            }
          },
          trailing: _isPhoneVerified
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: _kGreen, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: _kGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                )
              : (isPhoneComplete
                  ? GestureDetector(
                      onTap: isSendingOtp ? null : _handleSendOtp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kAccentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isSendingOtp
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  color: _kAccentBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                      ),
                    )
                  : null),
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.businessNameCtrl,
          hint: 'Business name as per GSTIN/ MSME',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.businessAddressCtrl,
          hint: 'Business address',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final statesAsync = ref.watch(getStateProvider);
                  return statesAsync.when(
                    initial: () => const _DropdownSkeleton(hint: 'State'),
                    loading: () =>
                        const _DropdownSkeleton(hint: 'State', isLoading: true),
                    error: (_) => const _DropdownSkeleton(hint: 'State'),
                    data: (states) => _SearchableDropdown(
                      hint: 'State',
                      value: logic.selectedStateId,
                      items: [
                        for (final s in states)
                          DropdownSearchItem(
                            id: s.stateId.toString(),
                            label: s.stateName ?? '',
                          ),
                      ],
                      onChanged: (id) {
                        if (id == null) return;
                        final matched = states
                            .where((s) => s.stateId.toString() == id)
                            .firstOrNull;
                        setState(() {
                          logic.selectedStateId = id;
                          logic.selectedStateName = matched?.stateName;
                          logic.selectedCityId = null;
                        });
                        _fetchCities(id);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final stateId = logic.selectedStateId;
                  if (stateId == null) {
                    return const _DropdownSkeleton(
                      hint: 'Select State First',
                      enabled: false,
                    );
                  }
                  final citiesAsync = ref.watch(getCityProvider);
                  return citiesAsync.when(
                    initial: () => const _DropdownSkeleton(hint: 'City'),
                    loading: () =>
                        const _DropdownSkeleton(hint: 'City', isLoading: true),
                    error: (_) => const _DropdownSkeleton(hint: 'City'),
                    data: (cities) => _SearchableDropdown(
                      hint: 'City',
                      value: logic.selectedCityId,
                      items: [
                        for (final c in cities)
                          DropdownSearchItem(
                            id: c.cityId.toString(),
                            label: c.cityName ?? '',
                          ),
                      ],
                      onChanged: (id) {
                        setState(() {
                          logic.selectedCityId = id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.pincodeCtrl,
          hint: 'Pincode',
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        _NextButton(
          enabled: logic.isBusinessInfoValid && _isPhoneVerified,
          onTap: () {
            if (!_isPhoneVerified) {
              Fluttertoast.showToast(
                  msg: 'Please verify your phone number first');
              return;
            }
            widget.onNext();
          },
        ),
      ],
    );
  }
}

class _OtpVerificationSheet extends ConsumerStatefulWidget {
  final String phone;
  final VoidCallback onVerified;
  const _OtpVerificationSheet({required this.phone, required this.onVerified});

  @override
  ConsumerState<_OtpVerificationSheet> createState() =>
      _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends ConsumerState<_OtpVerificationSheet> {
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      Fluttertoast.showToast(msg: 'Please enter a valid OTP');
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(verifyOtpProvider.notifier).verifyOtp(
          VerifyOtpModel(phone: widget.phone, otp: otp, isRegistered: false),
        );

    if (!mounted) return;

    final verifyState = ref.read(verifyOtpProvider);
    verifyState.whenOrNull(
      data: (userModel) {
        final message = (userModel.message ?? '').toLowerCase();
        final isSuccess = userModel.success == true ||
            message.contains('otp verified successfully') ||
            userModel.data?.userId != null;

        if (isSuccess) {
          Navigator.pop(context);
          widget.onVerified();
        } else {
          Fluttertoast.showToast(
              msg: userModel.message ?? 'Verification failed');
        }
      },
      error: (msg) => Fluttertoast.showToast(msg: msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVerifying = ref.watch(verifyOtpProvider).maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verify Phone Number',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: _kDark),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: _kGrey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the OTP sent to +91 ${widget.phone}',
            style: const TextStyle(fontSize: 13, color: _kGrey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              hintStyle:
                  const TextStyle(letterSpacing: 8, color: Color(0xFFC3C6D4)),
              filled: true,
              fillColor: const Color(0xFFF6F7FB),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isVerifying ? null : _verifyOtp,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isVerifying ? Colors.grey.shade300 : _kAccentBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isVerifying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownSearchItem {
  final String id;
  final String label;

  const DropdownSearchItem({required this.id, required this.label});
}

class _SearchableDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownSearchItem> items;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const _SearchableDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  void _openSearchSheet(BuildContext context) {
    if (!enabled) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchBottomSheet(
        title: 'Select $hint',
        hintText: 'Search $hint...',
        items: items,
        selectedId: value,
        onSelected: (selectedItem) {
          Navigator.pop(context);
          onChanged(selectedItem.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.where((e) => e.id == value).firstOrNull;
    final displayText = selectedItem?.label ?? hint;
    final hasValue = selectedItem != null;

    return GestureDetector(
      onTap: () => _openSearchSheet(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF6F7FB) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  color: hasValue
                      ? _kDark
                      : (enabled
                          ? const Color(0xFF9AA0B4)
                          : Colors.grey.shade400),
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? const Color(0xFF9AA0B4) : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final List<DropdownSearchItem> items;
  final String? selectedId;
  final ValueChanged<DropdownSearchItem> onSelected;

  const _SearchBottomSheet({
    required this.title,
    required this.hintText,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final _searchCtrl = TextEditingController();
  late List<DropdownSearchItem> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.label.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, size: 22, color: _kGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: _kDark),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    const TextStyle(color: Color(0xFF9AA0B4), fontSize: 13),
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 20, color: _kGrey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _kBorder),
          const SizedBox(height: 6),
          Flexible(
            child: _filteredItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No options found',
                      style: TextStyle(color: _kGrey, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item.id == widget.selectedId;

                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? _kAccentBlue : _kDark,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: _kAccentBlue, size: 20)
                            : null,
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DropdownSkeleton extends StatefulWidget {
  final String hint;
  final bool enabled;
  final bool isLoading;

  const _DropdownSkeleton({
    required this.hint,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  State<_DropdownSkeleton> createState() => _DropdownSkeletonState();
}

class _DropdownSkeletonState extends State<_DropdownSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    if (widget.isLoading) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _DropdownSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.isLoading && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? Colors.grey.shade300.withOpacity(_animation.value)
                : (widget.enabled
                    ? const Color(0xFFF6F7FB)
                    : const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.hint,
                style: TextStyle(
                  color: widget.enabled
                      ? const Color(0xFF9AA0B4)
                      : Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),
              if (widget.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.enabled
                      ? const Color(0xFF9AA0B4)
                      : Colors.grey.shade400,
                  size: 20,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;
  final bool enabled;

  const _PhoneField({
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                const BoxDecoration(color: _kFaintBg, shape: BoxShape.circle),
            child:
                const Icon(Icons.call_rounded, size: 18, color: _kAccentBlue),
          ),
          const SizedBox(width: 12),
          const Text('+91',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _kDark)),
          const SizedBox(width: 12),
          Container(width: 1.5, height: 24, color: _kBorder),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              onChanged: onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: enabled ? _kDark : Colors.grey.shade600),
              decoration: const InputDecoration(
                hintText: 'Mobile Number',
                hintStyle: TextStyle(
                    color: Color(0xFFC3C6D4), fontWeight: FontWeight.w500),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _NextButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? _kAccentBlue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Next',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _NameMatchBanner extends StatelessWidget {
  final NameMatchStatus status;
  final SignUpLogic logic;
  const _NameMatchBanner({required this.status, required this.logic});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case NameMatchStatus.checking:
        return const _Banner(
          color: Color(0xFFEDEFF7),
          textColor: _kGrey,
          icon: Icons.hourglass_top_rounded,
          text: 'Checking name on documents...',
        );
      case NameMatchStatus.matched:
        return const _Banner(
          color: Color(0xFFE7F7EE),
          textColor: Color(0xFF1FAA59),
          icon: Icons.check_circle_outline,
          text: 'Names on documents match.',
        );
      case NameMatchStatus.mismatched:
        return _Banner(
          color: const Color(0xFFFDECEC),
          textColor: const Color(0xFFD64545),
          icon: Icons.error_outline,
          text:
              'Identity doc shows "${logic.aadhaarGuessedName ?? '?'}" but PAN shows '
              '"${logic.panGuessedName ?? '?'}" — please re-check the photos.',
        );
      case NameMatchStatus.failed:
        return const _Banner(
          color: Color(0xFFFFF6E5),
          textColor: Color(0xFFB07B00),
          icon: Icons.warning_amber_rounded,
          text: "Couldn't read the name clearly — retake in better light.",
        );
      case NameMatchStatus.notChecked:
        return const SizedBox.shrink();
    }
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final Color textColor;
  final IconData icon;
  final String text;
  const _Banner(
      {required this.color,
      required this.textColor,
      required this.icon,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(text, style: TextStyle(fontSize: 12, color: textColor))),
        ],
      ),
    );
  }
}

class _SecurityDepositSection extends StatefulWidget {
  final SignUpLogic logic;
  final VoidCallback onPickReceipt;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  const _SecurityDepositSection({
    required this.logic,
    required this.onPickReceipt,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<_SecurityDepositSection> createState() =>
      _SecurityDepositSectionState();
}

class _SecurityDepositSectionState extends State<_SecurityDepositSection> {
  static const _apps = ['GPay', 'Paytm'];

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                '₹${SignUpLogic.depositAmount}',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 28, color: _kDark),
              ),
              SizedBox(height: 4),
              Text('Refundable deposit',
                  style: TextStyle(color: _kGrey, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please deposit a fully refundable amount to start participating in '
          'auctions. This amount will be added to your wallet, which you can '
          'use to start bidding.',
          style: TextStyle(color: _kGrey, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text('Select UPI App',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: _kDark, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: _apps.map((app) {
            final selected = logic.selectedUpiApp == app;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => setState(() => logic.selectedUpiApp = app),
                child: Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected ? _kAccentBlue : _kBorder,
                        width: selected ? 2 : 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        app == 'GPay'
                            ? Icons.g_mobiledata_rounded
                            : Icons.account_balance_wallet_outlined,
                        color: selected ? _kAccentBlue : _kGrey,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(app,
                          style: TextStyle(
                              fontSize: 12,
                              color: selected ? _kAccentBlue : _kGrey,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _RoundedField(
          controller: logic.referenceIdCtrl,
          hint: 'UPI Reference / Transaction ID',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        UploadTile(
          label: 'Payment screenshot',
          required: true,
          icon: Icons.receipt_long_outlined,
          actionText: 'Upload payment screenshot',
          file: logic.paymentReceipt,
          onTap: widget.onPickReceipt,
          onRetake: widget.onPickReceipt,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: (logic.isSecurityDepositValid && !widget.isSubmitting)
              ? widget.onSubmit
              : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: (logic.isSecurityDepositValid && !widget.isSubmitting)
                  ? _kAccentBlue
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Submit for review',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }
}
