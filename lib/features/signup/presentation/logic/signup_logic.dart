// lib/features/signup/presentation/logic/signup_logic.dart
//
// Backs the single SignUpPage (the 5-step accordion). No separate OTP
// step, so the mobile number is a regular field here. Fields below now
// match what POST /auth/register actually needs: first/last name, email,
// state+city as IDs (picked from dropdowns backed by location_provider.dart),
// plus a payment reference/amount/receipt captured in Security Deposit.

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

/// Which of the 5 accordion sections is open (-1 = none).
final expandedSectionProvider = StateProvider<int>((ref) => 0);

/// Per-section completion, drives the green check-mark in the header.
final sectionCompleteProvider =
    StateProvider<List<bool>>((ref) => List.filled(5, false));

final nameMatchStatusProvider =
    StateProvider<NameMatchStatus>((ref) => NameMatchStatus.notChecked);

class SignUpLogic {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
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
  static const depositAmount = '3000'; // TODO: confirm the real deposit amount
  File? paymentReceipt;

  final images = OnboardingImages();
  final nameMatchService = NameMatchService();

  String? aadhaarGuessedName;
  String? panGuessedName;

  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  bool get isBusinessInfoValid =>
      firstNameCtrl.text.trim().isNotEmpty &&
      lastNameCtrl.text.trim().isNotEmpty &&
      _emailRegex.hasMatch(emailCtrl.text.trim()) &&
      phoneCtrl.text.trim().length == 10 &&
      businessNameCtrl.text.trim().isNotEmpty &&
      businessAddressCtrl.text.trim().isNotEmpty &&
      pincodeCtrl.text.trim().length == 6 &&
      selectedStateId != null &&
      selectedCityId != null;

  bool get isOwnerPhotoValid =>
      images.ownerSelfie != null && images.placeOfBusiness != null;

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
    phoneCtrl.dispose();
    phoneFocus.dispose();
    businessNameCtrl.dispose();
    businessAddressCtrl.dispose();
    pincodeCtrl.dispose();
    referenceIdCtrl.dispose();
    nameMatchService.dispose();
  }
}
