class SendOtpModel {
  final String? phone;
  final bool? success;
  final String? message;
  final bool? isRegistered;
  final String? role;
  final int? source;

  SendOtpModel({
    this.phone,
    this.success,
    this.message,
    this.isRegistered,
    this.role,
    this.source,
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
    };
  }
}
