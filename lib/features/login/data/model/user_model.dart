class UserModel {
  final UserData data;
  final bool success;
  final String message;

  UserModel({
    required this.data,
    required this.success,
    required this.message,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      data: UserData.fromJson(json['data']),
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'success': success,
      'message': message,
    };
  }
}

class UserData {
  final String phoneNumber;
  final String fullName;
  final String userType;
  final int userId;
  final String email;
  final String username;

  UserData({
    required this.phoneNumber,
    required this.fullName,
    required this.userType,
    required this.userId,
    required this.email,
    required this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'],
      userType: json['userType'],
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
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
    };
  }
}
