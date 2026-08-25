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
  Future<UserData> verifyOtp(VerifyOtpModel model);
  Future<LogoutResponseModel> logout();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Ref ref;
  LoginRemoteDataSourceImpl(this.ref);

  // in-flight guards — defense in depth, on top of the LoginLogic-level guard
  Future<SendOtpModel>? _pendingSendOtp;
  Future<UserData>? _pendingVerifyOtp;

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
      const url = Url.sendOtp;

      // use params as-is — don't silently override its fields
      final map = params.toJson();

      final body = await ref.read(apiService).post(url, map);
      log('Response from API: $body');

      if (body == null) {
        throw 'API request failed';
      }

      if (body.data['success'] != true) {
        throw _extractMessage(body.data, fallback: 'OTP sending failed');
      }

      // Response body is typically just {success, message} — don't rely on
      // fields parsed from it beyond success/failure.
      return params;
    } catch (e) {
      log('Error occurred while sending OTP: $e');
      rethrow;
    }
  }

  @override
  Future<UserData> verifyOtp(VerifyOtpModel params) {
    if (_pendingVerifyOtp != null) return _pendingVerifyOtp!;

    final future = _verifyOtp(params);
    _pendingVerifyOtp = future;
    future.whenComplete(() => _pendingVerifyOtp = null);
    return future;
  }

  Future<UserData> _verifyOtp(VerifyOtpModel params) async {
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

      final user = UserData.fromJson(response.data['data']);
      logic.setUser(user);
      log('User set in DashBoardLogic: ${user.username}, ${user.userId}');
      await SecureStorageService().saveLogin(
        user: user,
        password: params.phone ?? '',
      );
      return user;
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
