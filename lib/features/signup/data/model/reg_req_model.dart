import 'package:dio/dio.dart';

class RegisterRequestModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String password;
  final String state; // state ID, from Url.stateUrl
  final String city; // city ID, from Url.cityUrl
  final String pincode;
  final String userType;
  final String subRole;
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
    required this.password,
    required this.state,
    required this.city,
    required this.pincode,
    this.userType = 'DEALER',
    this.subRole = 'BANK_DEALER',
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
      'user.password': password,
      'user.state': state,
      'user.city': city,
      'user.pincode': pincode,
      'user.userType': userType,
      'subRole': subRole,
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
