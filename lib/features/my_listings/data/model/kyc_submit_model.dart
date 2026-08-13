import 'package:dio/dio.dart';

class KycSubmitRequest {
  final String? vehicleId;
  final String? firstName;
  final String? middleInitial;
  final String? lastName;
  final String? suffix;
  final String? address;
  final String? state;
  final String? city;
  final String? pincode;
  final String? mobileNo;
  final String? email;
  final String? aadhaarFilePath;
  final String? panFilePath;

  KycSubmitRequest({
    this.vehicleId,
    this.firstName,
    this.middleInitial,
    this.lastName,
    this.suffix,
    this.address,
    this.state,
    this.city,
    this.pincode,
    this.mobileNo,
    this.email,
    this.aadhaarFilePath,
    this.panFilePath,
  });

  /// Builds the multipart payload the backend expects — matches the
  /// Postman request: text fields + aadhaarFile/panFile as file parts.
  Future<FormData> toFormData() async {
    return FormData.fromMap({
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (firstName != null) 'firstName': firstName,
      if (middleInitial != null) 'middleInitial': middleInitial,
      if (lastName != null) 'lastName': lastName,
      if (suffix != null) 'suffix': suffix,
      if (address != null) 'address': address,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      if (mobileNo != null) 'mobileNo': mobileNo,
      if (email != null) 'email': email,
      if (aadhaarFilePath != null)
        'aadhaarFile': await MultipartFile.fromFile(
          aadhaarFilePath!,
          filename: aadhaarFilePath!.split('/').last,
        ),
      if (panFilePath != null)
        'panFile': await MultipartFile.fromFile(
          panFilePath!,
          filename: panFilePath!.split('/').last,
        ),
    });
  }
}

class KycSubmitResponse {
  final bool success;
  final String msg;

  KycSubmitResponse({
    required this.success,
    required this.msg,
  });

  factory KycSubmitResponse.fromJson(Map<String, dynamic> json) {
    return KycSubmitResponse(
      success: json['success'] ?? false,
      msg: json['message'] ?? json['msg'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'msg': msg,
    };
  }
}
