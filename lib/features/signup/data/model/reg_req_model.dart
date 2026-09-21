// lib/features/signup/data/model/register_request_model.dart
//
// Field names here are literal multipart field names (Java/Spring-style
// dotted names — e.g. "user.firstName" — not real nested JSON), matching
// the curl exactly:
//
//   user.firstName, user.lastName, user.phoneNumber, user.email,
//   user.state, user.city, user.pincode, user.userType
//   aadhaarFrontCard, aadhaarBackCard, pancard, paymentReceipt   (files)
//   payments.paymentMethod, payments.amount, payments.referenceId
//
// Plain class — no freezed. This is built once, right before submit, and
// never mutated or compared, so copyWith/== would be dead weight.

import 'package:dio/dio.dart';

class RegisterRequestModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String state; // state ID, from Url.stateUrl
  final String city; // city ID, from Url.cityUrl
  final String pincode;
  final String userType;
  final String aadhaarFrontCardPath;
  final String aadhaarBackCardPath;
  final String pancardPath;
  final String paymentReceiptPath;
  final String paymentMethod;
  final String amount;
  final String referenceId;

  RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.state,
    required this.city,
    required this.pincode,
    this.userType = 'DEALER',
    required this.aadhaarFrontCardPath,
    required this.aadhaarBackCardPath,
    required this.pancardPath,
    required this.paymentReceiptPath,
    this.paymentMethod = 'UPI',
    required this.amount,
    required this.referenceId,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'user.firstName': firstName,
      'user.lastName': lastName,
      'user.phoneNumber': phoneNumber,
      'user.email': email,
      'user.state': state,
      'user.city': city,
      'user.pincode': pincode,
      'user.userType': userType,
      'aadhaarFrontCard': await MultipartFile.fromFile(
        aadhaarFrontCardPath,
        filename: _fileName(aadhaarFrontCardPath),
      ),
      'aadhaarBackCard': await MultipartFile.fromFile(
        aadhaarBackCardPath,
        filename: _fileName(aadhaarBackCardPath),
      ),
      'pancard': await MultipartFile.fromFile(
        pancardPath,
        filename: _fileName(pancardPath),
      ),
      'paymentReceipt': await MultipartFile.fromFile(
        paymentReceiptPath,
        filename: _fileName(paymentReceiptPath),
      ),
      'payments.paymentMethod': paymentMethod,
      'payments.amount': amount,
      'payments.referenceId': referenceId,
    });
  }

  static String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;
}
