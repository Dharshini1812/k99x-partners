class UserModel {
  String? role;
  String? phoneNumber;
  bool? success;
  String? message;
  int? userId;
  String? username;

  UserModel(
      {this.role,
      this.phoneNumber,
      this.success,
      this.message,
      this.userId,
      this.username});

  UserModel.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    phoneNumber = json['phoneNumber'];
    success = json['success'];
    message = json['message'];
    userId = json['userId'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['phoneNumber'] = phoneNumber;
    data['success'] = success;
    data['message'] = message;
    data['userId'] = userId;
    data['username'] = username;
    return data;
  }
}
