class SendOtpModel {
  final String? phone;
  final bool? success;
  final String? message;
  final bool? isRegistered;
  final String? role;
  final int? source;
  final bool? forceLogin;
  final bool? resend;

  SendOtpModel({
    this.phone,
    this.success,
    this.message,
    this.isRegistered,
    this.role,
    this.source,
    this.forceLogin,
    this.resend,
  });

  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'isRegistered': isRegistered,
      'role': role,
      'source': source,
      'forceLogin': forceLogin,
      'resend': resend,
    };
  }

  /// GET /auth/otp/send now takes these as query params, not a JSON
  /// body — role/source aren't part of that contract, only
  /// forceLogin/isRegistered/phone/resend are. Missing bools default to
  /// false to match the shape you showed (forceLogin=false&resend=false).
  Map<String, String> toQueryParams() {
    return {
      'forceLogin': (forceLogin ?? false).toString(),
      'isRegistered': (isRegistered ?? false).toString(),
      'phone': phone ?? '',
      'resend': (resend ?? false).toString(),
    };
  }
}
