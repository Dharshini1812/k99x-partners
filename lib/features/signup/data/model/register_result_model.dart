// lib/features/signup/data/model/register_response_model.dart
//
// Matches:
// { "data": { "userType": "DEALER", "userId": 201, "username": "XDTN00008" },
//   "success": true, "message": "Registration successful!" }
//
// Plain classes, same style as your RegisterResult — no freezed, no
// codegen. A response you only ever read (never build/copy/compare)
// doesn't need what freezed gives you.

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
  final String? userType;
  final int? userId;
  final String? username;

  RegisterResult({this.userType, this.userId, this.username});

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      userType: json['userType']?.toString(),
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse('${json['userId']}'),
      username: json['username']?.toString(),
    );
  }
}
