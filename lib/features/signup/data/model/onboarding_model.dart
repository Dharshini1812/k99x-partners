import 'dart:io';

class OnboardingImages {
  File? ownerSelfie;
  File? placeOfBusiness;
  File? aadhaarFront;
  File? aadhaarBack;
  File? panCard;
  File? paymentReceipt;
  final Map<String, File> businessDocs;

  OnboardingImages({
    this.ownerSelfie,
    this.placeOfBusiness,
    this.aadhaarFront,
    this.aadhaarBack,
    this.panCard,
    this.paymentReceipt,
    Map<String, File>? businessDocs,
  }) : businessDocs = businessDocs ?? {};
}

/// Result of comparing the name printed on Aadhaar vs PAN, via on-device OCR.
enum NameMatchStatus { notChecked, checking, matched, mismatched, failed }
