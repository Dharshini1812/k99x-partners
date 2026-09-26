class RegisterResponse {
  final bool success;
  final String message;
  final RegisterResult? data;

  RegisterResponse({required this.success, required this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? RegisterResult.fromJson(
              Map<String, dynamic>.from(json['data'] as Map))
          : null,
    );
  }
}

class RegisterResult {
  final String? subRole;
  final String? userType;
  final String? userId;
  final String? username;

  RegisterResult({this.subRole, this.userType, this.userId, this.username});

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      subRole: json['subRole']?.toString(),
      userType: json['userType']?.toString(),
      userId: json['userId']?.toString(),
      username: json['username']?.toString(),
    );
  }
}
