class UserModel {
  final UserData? data;
  final bool success;
  final String? message;

  UserModel({
    this.data,
    this.success = false,
    this.message,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'success': success,
      'message': message,
    };
  }
}

class UserData {
  final String? phoneNumber;
  final String? fullName;
  final String? userType;
  final int? userId;
  final String? email;
  final String? username;
  final String? lenderName;
  final int? lenderId;
  final String? cityName;
  final String? stateName;

  UserData({
    this.phoneNumber,
    this.fullName,
    this.userType,
    this.userId,
    this.email,
    this.username,
    this.lenderName,
    this.lenderId,
    this.cityName,
    this.stateName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      phoneNumber: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String?,
      userType: json['userType'] as String?,
      userId: json['userId'] as int?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      lenderName: json['lenderName'] as String?,
      lenderId: json['lenderId'] as int?,
      cityName: json['cityName'] as String?,
      stateName: json['stateName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'userType': userType,
      'userId': userId,
      'email': email,
      'username': username,
      'lenderName': lenderName,
      'lenderId': lenderId,
    };
  }
}
