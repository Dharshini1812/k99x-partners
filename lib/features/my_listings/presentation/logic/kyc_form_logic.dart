import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart'; // adjust to wherever KycSubmitRequest/Response live
import 'package:dealer/features/my_listings/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final kycFormLogic = ChangeNotifierProvider.autoDispose
    .family<KycFormLogic, String>((ref, vehicleId) {
  return KycFormLogic(ref: ref, vehicleId: vehicleId);
});

class KycFormLogic extends ChangeNotifier {
  final Ref ref;
  final String vehicleId;

  KycFormLogic({required this.ref, required this.vehicleId});

  static const List<String> allBanks = [
    'Equitas',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra',
    'IDFC First',
    'SBI',
    'Bank of Baroda',
  ];

  // ── Banks ────────────────────────────────────────────────
  Set<String> selectedBanks = {...allBanks};

  String get bankTriggerLabel {
    if (selectedBanks.length == allBanks.length) return 'All Banks';
    if (selectedBanks.isEmpty) return 'No Banks';
    if (selectedBanks.length == 1) return selectedBanks.first;
    return '${selectedBanks.length} Banks';
  }

  void setSelectedBanks(Set<String> banks) {
    selectedBanks = banks;
    notifyListeners();
  }

  // ── Text fields ──────────────────────────────────────────
  final firstNameController = TextEditingController();
  final middleInitialController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final pinCodeController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  String? suffix;
  void setSuffix(String? v) {
    suffix = v;
    notifyListeners();
  }

  // ── State / City ─────────────────────────────────────────
  StateModel? selectedState;
  CityModel? selectedCity;

  void setSelectedState(StateModel? v) {
    selectedState = v;
    selectedCity = null; // reset — city list is about to change
    notifyListeners();
  }

  void setSelectedCity(CityModel? v) {
    selectedCity = v;
    notifyListeners();
  }

  // ── Documents ────────────────────────────────────────────
  final ImagePicker picker = ImagePicker();
  XFile? aadhaarFile;
  XFile? panFile;

  void setAadhaarFile(XFile? file) {
    aadhaarFile = file;
    notifyListeners();
  }

  void setPanFile(XFile? file) {
    panFile = file;
    notifyListeners();
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
    } catch (_) {
      return null;
    }
  }

  String? mobileError;
  String? pinCodeError;

  void validateMobile() {
    final value = mobileController.text.trim();
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');

    if (value.isEmpty) {
      mobileError = 'Mobile number is required';
    } else if (!mobileRegex.hasMatch(value)) {
      mobileError = 'Enter a valid 10-digit mobile number';
    } else {
      mobileError = null;
    }

    notifyListeners();
  }

  void validatePinCode() {
    final value = pinCodeController.text.trim();
    final pinRegex = RegExp(r'^\d{6}$');

    if (value.isEmpty) {
      pinCodeError = 'PIN code is required';
    } else if (!pinRegex.hasMatch(value)) {
      pinCodeError = 'Enter a valid 6-digit PIN code';
    } else {
      pinCodeError = null;
    }

    notifyListeners();
  }

  // ── Submit state ─────────────────────────────────────────
  bool isSubmitting = false;
  String? submitError;

  String? validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      return 'First name is required';
    }
    if (lastNameController.text.trim().isEmpty) return 'Last name is required';
    if (addressController.text.trim().isEmpty) return 'Address is required';
    if (selectedState == null) return 'Please select a state';
    if (selectedCity == null) return 'Please select a city';
    if (pinCodeController.text.trim().isEmpty) return 'Pin code is required';
    if (mobileController.text.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (emailController.text.trim().isEmpty) return 'Email is required';
    if (aadhaarFile == null) return 'Please upload your Aadhaar card';
    if (panFile == null) return 'Please upload your PAN card';
    return null;
  }

  /// Returns true on success, false on failure (check [submitError] for the
  /// message either way — validation or server error).
  Future<bool> submitKyc() async {
    final validationError = validateForm();
    if (validationError != null) {
      submitError = validationError;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    final request = KycSubmitRequest(
      vehicleId: vehicleId,
      firstName: firstNameController.text.trim(),
      middleInitial: middleInitialController.text.trim().isEmpty
          ? null
          : middleInitialController.text.trim(),
      lastName: lastNameController.text.trim(),
      suffix: suffix,
      address: addressController.text.trim(),
      state: selectedState?.stateName,
      city: selectedCity?.cityName,
      pincode: pinCodeController.text.trim(),
      mobileNo: mobileController.text.trim(),
      email: emailController.text.trim(),
      aadhaarFilePath: aadhaarFile?.path,
      panFilePath: panFile?.path,
    );

    try {
      final response =
          await ref.read(addKycNotifier.notifier).addKyc(data: request);

      isSubmitting = false;

      if (response == null) {
        // Notifier already pushed an AddKycState.error with the failure
        // message — surface that instead of a generic string.
        final notifierState = ref.read(addKycNotifier);
        submitError = notifierState.maybeWhen(
          error: (msg) => msg.isNotEmpty ? msg : 'KYC submission failed',
          orElse: () => 'KYC submission failed',
        );
        notifyListeners();
        return false;
      }

      if (!response.success) {
        submitError =
            response.msg.isNotEmpty ? response.msg : 'KYC submission failed';
        notifyListeners();
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      submitError = 'Something went wrong: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleInitialController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
