// lib/features/signup/presentation/logic/signup_logic.dart
//
// Backs the single SignUpPage — now a 3-step accordion (Business
// Information / Personal documents / Security Deposit), trimmed down to
// exactly what POST /auth/register needs. The "Owner & dealership photo"
// and "Business Documents" steps were removed from the page — the curl
// only ever sends aadhaarFrontCard/aadhaarBackCard/pancard/paymentReceipt,
// never a selfie, a place-of-business photo, or GST/MSME/etc., so forcing
// the user through two extra steps that get thrown away was pointless
// friction. `images.ownerSelfie`, `images.placeOfBusiness`, and
// `images.businessDocs` still exist on OnboardingImages (harmless if
// unused) but nothing in the UI writes to them anymore.

import 'dart:io';
import 'package:dealer/core/services/name_match_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/onboarding_model.dart';

final signUpLogicProvider = Provider<SignUpLogic>((ref) {
  final logic = SignUpLogic();
  ref.onDispose(logic.dispose);
  return logic;
});

/// Which of the 3 accordion sections is open (-1 = none).
final expandedSectionProvider = StateProvider<int>((ref) => 0);

/// Per-section completion, drives the green check-mark in the header.
final sectionCompleteProvider =
    StateProvider<List<bool>>((ref) => List.filled(3, false));

final nameMatchStatusProvider =
    StateProvider<NameMatchStatus>((ref) => NameMatchStatus.notChecked);

class SignUpLogic {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final phoneFocus = FocusNode();
  final businessNameCtrl = TextEditingController();
  final businessAddressCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  // Selected via the State/City dropdowns (see location_provider.dart).
  // Plain fields mutated with setState from the page, same pattern as
  // `images` below — consistent with how this class already works.
  String? selectedStateId;
  String? selectedStateName;
  String? selectedCityId;

  // Security Deposit step.
  String selectedUpiApp = 'GPay';
  final referenceIdCtrl = TextEditingController();
  static const depositAmount = '3000';
  File? paymentReceipt;

  final images = OnboardingImages();
  final nameMatchService = NameMatchService();

  String? aadhaarGuessedName;
  String? panGuessedName;

  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  // Matches the curl example's password shape loosely: 8+ chars with at
  // least one letter and one digit. Tighten/loosen to whatever the
  // backend actually enforces once that's documented — this is a
  // reasonable client-side floor, not a confirmed server rule.
  bool get isPasswordValid {
    final p = passwordCtrl.text;
    return p.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(p) &&
        RegExp(r'[0-9]').hasMatch(p);
  }

  bool get passwordsMatch =>
      passwordCtrl.text.isNotEmpty &&
      passwordCtrl.text == confirmPasswordCtrl.text;

  bool get isBusinessInfoValid =>
      firstNameCtrl.text.trim().isNotEmpty &&
      lastNameCtrl.text.trim().isNotEmpty &&
      _emailRegex.hasMatch(emailCtrl.text.trim()) &&
      isPasswordValid &&
      passwordsMatch &&
      phoneCtrl.text.trim().length == 10 &&
      businessNameCtrl.text.trim().isNotEmpty &&
      businessAddressCtrl.text.trim().isNotEmpty &&
      pincodeCtrl.text.trim().length == 6 &&
      selectedStateId != null &&
      selectedCityId != null;

  bool get isPersonalDocsValid =>
      images.aadhaarFront != null &&
      images.aadhaarBack != null &&
      images.panCard != null;

  bool get isSecurityDepositValid =>
      referenceIdCtrl.text.trim().isNotEmpty && paymentReceipt != null;

  /// Runs OCR on the Aadhaar + PAN photos and fuzzy-compares the names.
  /// Callers should show this as a dismissible warning, not a hard block —
  /// OCR on a phone photo of an ID card is never fully reliable.
  Future<NameMatchStatus> checkNameMatch() async {
    if (images.aadhaarFront == null || images.panCard == null) {
      return NameMatchStatus.notChecked;
    }
    try {
      final aadhaar = await nameMatchService.extractText(images.aadhaarFront!);
      final pan = await nameMatchService.extractText(images.panCard!);
      aadhaarGuessedName = aadhaar.guessedName;
      panGuessedName = pan.guessedName;

      if (aadhaarGuessedName == null || panGuessedName == null) {
        return NameMatchStatus.failed;
      }
      return nameMatchService.namesLikelyMatch(
              aadhaarGuessedName!, panGuessedName!)
          ? NameMatchStatus.matched
          : NameMatchStatus.mismatched;
    } catch (_) {
      return NameMatchStatus.failed;
    }
  }

  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    phoneCtrl.dispose();
    phoneFocus.dispose();
    businessNameCtrl.dispose();
    businessAddressCtrl.dispose();
    pincodeCtrl.dispose();
    referenceIdCtrl.dispose();
    nameMatchService.dispose();
  }
}
