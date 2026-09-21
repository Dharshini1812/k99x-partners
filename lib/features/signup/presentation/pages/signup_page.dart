import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/signup/data/model/reg_req_model.dart';
import 'package:dealer/features/signup/presentation/logic/register/register_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../data/model/onboarding_model.dart';
import '../logic/signup_logic.dart';
import '../widgets/oval_selfie_camera.dart';
import '../widgets/upload_tile.dart';
import '../widgets/section_wrapper.dart';

const _kAccentBlue = Color(0xFF3B4EF5);
const _kDark = Color(0xFF11142A);
const _kGrey = Color(0xFF8B8FA3);
const _kFaintBg = Color(0xFFEDEFF7);
const _kBorder = Color(0xFFE7E8F0);

@AutoRoute()
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _picker = ImagePicker();

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

  Future<void> _captureSelfie(SignUpLogic logic) async {
    final file = await Navigator.of(context).push<File>(
      MaterialPageRoute(builder: (_) => const OvalSelfieCameraPage()),
    );
    if (file != null) setState(() => logic.images.ownerSelfie = file);
  }

  Future<void> _pickPlaceOfBusiness(SignUpLogic logic) async {
    final file = await _pickImage(cameraOnly: true);
    if (file != null) setState(() => logic.images.placeOfBusiness = file);
  }

  Future<void> _pickReceipt(SignUpLogic logic) async {
    final file = await _pickImage(cameraOnly: false);
    if (file != null) setState(() => logic.paymentReceipt = file);
  }

  Future<void> _pickDoc(SignUpLogic logic, void Function(File) assign) async {
    final file = await _pickImage(cameraOnly: false);
    if (file == null) return;
    setState(() => assign(file));
    // Re-run the Aadhaar/PAN name check whenever either doc changes.
    if (logic.images.aadhaarFront != null && logic.images.panCard != null) {
      ref.read(nameMatchStatusProvider.notifier).state =
          NameMatchStatus.checking;
      final status = await logic.checkNameMatch();
      ref.read(nameMatchStatusProvider.notifier).state = status;
    }
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
    ref.read(expandedSectionProvider.notifier).state = next < 5 ? next : -1;
  }

  /// Final "Submit for review" action — builds the /auth/register payload
  /// from everything collected across the 5 steps and fires it.
  ///
  /// NOTE: owner selfie, place-of-business photo, and the Business
  /// Documents uploads (GST/MSME/etc.) are NOT part of the register call
  /// per the curl you shared — that endpoint only takes Aadhaar, PAN, and
  /// a payment receipt. Those other files are collected here but not sent
  /// yet; they likely belong to a follow-up KYC call (Url.uploadKyc) once
  /// the account exists. Flagging rather than guessing at that contract.
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
            paymentMethod: logic.selectedUpiApp,
            amount: SignUpLogic.depositAmount,
            referenceId: logic.referenceIdCtrl.text.trim(),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A3DE8), Color(0xFF9B4DE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Explore app via free trial ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    OnboardingSection(
                      stepNumber: 1,
                      totalSteps: 5,
                      title: 'Business Information',
                      isExpanded: expanded == 0,
                      isCompleted: completed[0],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 0 ? -1 : 0,
                      child: _BusinessInfoForm(
                        logic: logic,
                        onNext: () => _goNext(0, logic.isBusinessInfoValid),
                      ),
                    ),
                    OnboardingSection(
                      stepNumber: 2,
                      totalSteps: 5,
                      title: 'Owner & dealership photo',
                      isExpanded: expanded == 1,
                      isCompleted: completed[1],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 1 ? -1 : 1,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UploadTile(
                                  label: "Owner's selfie",
                                  required: true,
                                  icon: Icons.camera_alt_outlined,
                                  actionText: 'Click selfie',
                                  isCircular: true,
                                  file: logic.images.ownerSelfie,
                                  onTap: () => _captureSelfie(logic),
                                  onRetake: () => _captureSelfie(logic),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: UploadTile(
                                  label: 'Place of business',
                                  required: true,
                                  icon: Icons.camera_alt_outlined,
                                  actionText: 'Click dealership photo',
                                  file: logic.images.placeOfBusiness,
                                  onTap: () => _pickPlaceOfBusiness(logic),
                                  onRetake: () => _pickPlaceOfBusiness(logic),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: _kGrey),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'LOCATION ACCESS IS MANDATORY TO CLICK PHOTOS',
                                  style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                      color: _kGrey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _NextButton(
                              enabled: logic.isOwnerPhotoValid,
                              onTap: () => _goNext(1, logic.isOwnerPhotoValid)),
                        ],
                      ),
                    ),
                    OnboardingSection(
                      stepNumber: 3,
                      totalSteps: 5,
                      title: 'Personal documents',
                      isExpanded: expanded == 2,
                      isCompleted: completed[2],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 2 ? -1 : 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'Keep Aadhaar registered mobile number handy for OTP',
                              style: TextStyle(fontSize: 13, color: _kGrey)),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UploadTile(
                                  label: 'Aadhaar front photo',
                                  required: true,
                                  icon: Icons.upload_file_outlined,
                                  actionText: 'Upload Aadhaar front',
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
                                  label: 'Aadhaar back photo',
                                  required: true,
                                  icon: Icons.upload_file_outlined,
                                  actionText: 'Upload Aadhaar back',
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
                                    'Name on Aadhaar & PAN card should be same',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFE0A000))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _NextButton(
                              enabled: logic.isPersonalDocsValid,
                              onTap: () =>
                                  _goNext(2, logic.isPersonalDocsValid)),
                        ],
                      ),
                    ),
                    OnboardingSection(
                      stepNumber: 4,
                      totalSteps: 5,
                      title: 'Security Deposit',
                      isExpanded: expanded == 3,
                      isCompleted: completed[3],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 3 ? -1 : 3,
                      child: _SecurityDepositSection(
                        logic: logic,
                        onPickReceipt: () => _pickReceipt(logic),
                        onNext: () => _goNext(3, logic.isSecurityDepositValid),
                      ),
                    ),
                    OnboardingSection(
                      stepNumber: 5,
                      totalSteps: 5,
                      title: 'Business Documents',
                      isExpanded: expanded == 4,
                      isCompleted: completed[4],
                      onHeaderTap: () => ref
                          .read(expandedSectionProvider.notifier)
                          .state = expanded == 4 ? -1 : 4,
                      child: _BusinessDocumentsSection(
                        logic: logic,
                        onPick: _pickDoc,
                        isSubmitting: isSubmitting,
                        onSubmit: () => _submitRegistration(logic),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => ref
                            .read(routeService)
                            .push(const LoginRoute(), context),
                        child: const Text('Already have an account? Login',
                            style: TextStyle(
                                color: _kAccentBlue,
                                fontWeight: FontWeight.w600)),
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
  const _BusinessInfoForm({required this.logic, required this.onNext});

  @override
  ConsumerState<_BusinessInfoForm> createState() => _BusinessInfoFormState();
}

class _BusinessInfoFormState extends ConsumerState<_BusinessInfoForm> {
  // Fires widget.onNext() automatically the moment every required field
  // in this section is filled in — no manual "Next" tap needed. _pending
  // guards against firing again on every keystroke while already valid,
  // and re-arms itself if an edit makes the section invalid again (e.g.
  // they clear a field or change state after picking a city).
  bool _pending = true;

  void _maybeAutoAdvance() {
    final isValid = widget.logic.isBusinessInfoValid;
    if (isValid && _pending) {
      _pending = false;
      // Deferred to after this build finishes — onNext() touches Riverpod
      // state providers, which build() itself must not do.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onNext();
      });
    } else if (!isValid) {
      _pending = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;
    _maybeAutoAdvance();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RoundedField(
                  controller: logic.firstNameCtrl,
                  hint: 'First Name',
                  onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _RoundedField(
                  controller: logic.lastNameCtrl,
                  hint: 'Last Name',
                  onChanged: (_) => setState(() {})),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _RoundedField(
          controller: logic.emailCtrl,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _PhoneField(
          controller: logic.phoneCtrl,
          focusNode: logic.phoneFocus,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _RoundedField(
            controller: logic.businessNameCtrl,
            hint: 'Business name as per GSTIN/ MSME',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        _RoundedField(
            controller: logic.businessAddressCtrl,
            hint: 'Business address',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final statesAsync = ref.watch(getStateProvider);
                  return statesAsync.when(
                    initial: () => const CircleAvatar(),
                    loading: () => const _DropdownSkeleton(hint: 'State'),
                    error: (_) => const _DropdownSkeleton(hint: 'State'),
                    data: (states) => _RoundedDropdown(
                      hint: 'State',
                      value: logic.selectedStateId,
                      items: [
                        for (final s in states)
                          DropdownMenuItem(
                              value: s.stateId.toString(),
                              child: Text(s.stateName ?? ""))
                      ],
                      onChanged: (id) {
                        final name =
                            states.firstWhere((s) => s.stateId == id).stateName;
                        setState(() {
                          logic.selectedStateId = id;
                          logic.selectedStateName = name;
                          logic.selectedCityId =
                              null; // reset city on state change
                        });
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
                        hint: 'City', enabled: false);
                  }
                  final citiesAsync = ref.watch(getCityProvider);
                  return citiesAsync.when(
                    initial: () => const CircleAvatar(),
                    loading: () => const _DropdownSkeleton(hint: 'City'),
                    error: (_) => const _DropdownSkeleton(hint: 'City'),
                    data: (cities) => _RoundedDropdown(
                      hint: 'City',
                      value: logic.selectedCityId,
                      items: [
                        for (final c in cities)
                          DropdownMenuItem(
                              value: c.cityId.toString(),
                              child: Text(c.cityName ?? ''))
                      ],
                      onChanged: (id) =>
                          setState(() => logic.selectedCityId = id),
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
        _NextButton(enabled: logic.isBusinessInfoValid, onTap: widget.onNext),
      ],
    );
  }
}

class _RoundedDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _RoundedDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF9AA0B4))),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Loading/disabled placeholder shown while a dropdown's list is fetching,
/// or before a state is picked (for the City dropdown).
class _DropdownSkeleton extends StatelessWidget {
  final String hint;
  final bool enabled;
  const _DropdownSkeleton({required this.hint, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(14)),
      child: Text(hint, style: const TextStyle(color: Color(0xFF9AA0B4))),
    );
  }
}

/// Editable mobile number field — same look as login's phone field
/// (+91 prefix, call icon, digits-only) but just a plain form field here,
/// since there's no OTP step to gate it.
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  const _PhoneField({
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
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
              keyboardType: TextInputType.phone,
              onChanged: onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _kDark),
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

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
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
          text: 'Checking name on Aadhaar & PAN...',
        );
      case NameMatchStatus.matched:
        return const _Banner(
          color: Color(0xFFE7F7EE),
          textColor: Color(0xFF1FAA59),
          icon: Icons.check_circle_outline,
          text: 'Names on Aadhaar and PAN match.',
        );
      case NameMatchStatus.mismatched:
        return _Banner(
          color: const Color(0xFFFDECEC),
          textColor: const Color(0xFFD64545),
          icon: Icons.error_outline,
          text:
              'Aadhaar shows "${logic.aadhaarGuessedName ?? '?'}" but PAN shows '
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
  final VoidCallback onNext;
  const _SecurityDepositSection({
    required this.logic,
    required this.onPickReceipt,
    required this.onNext,
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
        Center(
          child: Column(
            children: [
              Text(
                '₹${SignUpLogic.depositAmount}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 28, color: _kDark),
              ),
              const SizedBox(height: 4),
              const Text('Refundable deposit',
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
        _NextButton(
            enabled: logic.isSecurityDepositValid, onTap: widget.onNext),
      ],
    );
  }
}

class _BusinessDocumentsSection extends StatelessWidget {
  final SignUpLogic logic;
  final Future<void> Function(SignUpLogic, void Function(File)) onPick;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  const _BusinessDocumentsSection({
    required this.logic,
    required this.onPick,
    required this.isSubmitting,
    required this.onSubmit,
  });

  static const _docs = [
    'GST Certificate',
    'MSME Certificate',
    'Shop Act License',
    'Cancelled Cheque'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._docs.map((label) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: UploadTile(
                label: label,
                required: true,
                icon: Icons.upload_file_outlined,
                actionText: 'Upload $label',
                file: logic.images.businessDocs[label],
                onTap: () =>
                    onPick(logic, (f) => logic.images.businessDocs[label] = f),
                onRetake: () =>
                    onPick(logic, (f) => logic.images.businessDocs[label] = f),
              ),
            )),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isSubmitting ? null : onSubmit,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSubmitting ? Colors.grey.shade300 : _kAccentBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isSubmitting
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
