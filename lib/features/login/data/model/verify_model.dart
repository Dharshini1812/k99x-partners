class VerifyOtpModel {
  String? phone;
  String? otp;
  bool? isRegistered;
  String? role;
  int? source;

  VerifyOtpModel(
      {this.phone, this.otp, this.isRegistered, this.role, this.source});

  VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    otp = json['otp'];
    isRegistered = json['isRegistered'];
    role = json['role'];
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['otp'] = otp;
    data['isRegistered'] = isRegistered;
    data['role'] = role;
    data['source'] = source;
    return data;
  }
}
