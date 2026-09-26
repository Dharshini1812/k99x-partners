import 'dart:async';
import 'dart:developer';
import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/login/data/model/logout_model.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class LoginRemoteDataSource {
  Future<SendOtpModel> sendOtp(SendOtpModel model);
  Future<UserModel> verifyOtp(VerifyOtpModel model);
  Future<LogoutResponseModel> logout();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Ref ref;
  LoginRemoteDataSourceImpl(this.ref);

  // in-flight guards — defense in depth, on top of the LoginLogic-level guard
  Future<SendOtpModel>? _pendingSendOtp;
  Future<UserModel>? _pendingVerifyOtp;

  @override
  Future<SendOtpModel> sendOtp(SendOtpModel params) {
    // If a send is already in flight, return that same future instead of
    // firing a second request.
    if (_pendingSendOtp != null) return _pendingSendOtp!;

    final future = _sendOtp(params);
    _pendingSendOtp = future;
    future.whenComplete(() => _pendingSendOtp = null);
    return future;
  }

  Future<SendOtpModel> _sendOtp(SendOtpModel params) async {
    try {
      final uri = Uri.parse(Url.sendOtp)
          .replace(queryParameters: params.toQueryParams());

      final response = await ref.read(apiService).post(
        uri.toString(),
        {},
        validateStatus: (status) {
          // Status 403 will pass through here instead of crashing Dio
          return status != null && status < 500;
        },
      );

      log('OTP Response => ${response.statusCode} - ${response.data}');

      if (response.data == null) {
        throw Exception('API request failed');
      }

      // DO NOT throw here if success == false. Return the model directly:
      return SendOtpModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } catch (e) {
      log('Error occurred while sending OTP: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> verifyOtp(VerifyOtpModel params) {
    if (_pendingVerifyOtp != null) return _pendingVerifyOtp!;

    final future = _verifyOtp(params);
    _pendingVerifyOtp = future;
    future.whenComplete(() => _pendingVerifyOtp = null);
    return future;
  }

  Future<UserModel> _verifyOtp(VerifyOtpModel params) async {
    try {
      final logic = ref.read(dLogic);
      const url = Url.verifyOtp;

      final map = params.toJson();

      final response = await ref.read(apiService).post(url, map);
      log('Response from API: ${response.data}');

      if (response.data == null) {
        throw 'Invalid response';
      }

      if (response.data['success'] != true) {
        throw _extractMessage(response.data,
            fallback: 'OTP verification failed');
      }

      // 1. Pass the entire response.data to UserModel.fromJson
      final userModel = UserModel.fromJson(response.data);

      // 2. If existing user (data is not null), save session and user info
      if (userModel.data != null) {
        final userData = userModel.data!;
        logic.setUser(userData);
        log('User set in DashBoardLogic: ${userData.username}, ${userData.userId}');

        await SecureStorageService().saveLogin(
          user: userData,
          password: params.phone ?? '',
        );
      } else {
        log('New user verified: ${userModel.message}');
      }

      return userModel;
    } catch (e) {
      log('Error occurred while verifying OTP: $e');
      rethrow;
    }
  }

  String _extractMessage(dynamic data, {required String fallback}) {
    final msg = data is Map ? data['message'] : null;
    if (msg == null) return fallback;
    if (msg is String) return msg;
    return msg.toString();
  }

  @override
  Future<LogoutResponseModel> logout() async {
    try {
      final api = ref.read(apiService);
      // post1 attaches getAuthHeaders() (Basic auth + X-USER-ID) — same
      // as every other authenticated call in this app. No body needed;
      // the server identifies the session from those headers.
      final response = await api.post1(Url.logoutUrl, null);

      // post1 returns the full Dio Response — the JSON body is in
      // response.data, not the Response wrapper itself.
      return LogoutResponseModel.fromJson(response.data);
    } catch (e) {
      log("Logout Error : $e");
      rethrow;
    }
  }
}
