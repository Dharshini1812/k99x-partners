import 'dart:developer';
import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/login/data/model/send_otp.dart';
import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:dealer/features/login/data/model/verify_model.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class LoginRemoteDataSource {
  Future<SendOtpModel> sendOtp(SendOtpModel model);
  Future<UserModel> verifyOtp(VerifyOtpModel model);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Ref ref;
  LoginRemoteDataSourceImpl(this.ref);
  @override
  Future<SendOtpModel> sendOtp(SendOtpModel params) async {
    try {
      // String url =
      //     'https://k99x.com/servlet/auth/otp/send?phone=${params.phone}&isRegistered=true&forceLogin=false&resend=false';
      String url = Url.sendOtp;
      // Map map = {};
      Map map = SendOtpModel(
        phone: params.phone,
        isRegistered: true,
        role: 'VALUATOR',
        source: 2,
      ).toJson();

      var body = await ref.read(apiService).post(url, map);
      log('Response from API: $body');

      if (body == null) {
        throw 'API request failed';
      }

      if (body.data['success'] != true) {
        throw body.data['message'] ?? 'OTP sending failed';
      }

      final model = SendOtpModel.fromJson(body.data);
      return model;
    } catch (e) {
      log('Error occurred while sending OTP: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> verifyOtp(VerifyOtpModel params) async {
    try {
      // final logic = ref.read(dashBoardLogic);
      // final url = 'https://k99x.com/servlet/auth/otp/verify'
      //     '?phone=${params.phone}'
      //     '&otp=${params.otp}'
      //     '&isRegistered=true';

      const url = Url.verifyOtp;
      Map map = VerifyOtpModel(
        phone: params.phone,
        otp: params.otp,
        isRegistered: params.isRegistered,
        role: params.role,
        source: params.source,
      ).toJson();

      final response = await ref.read(apiService).post(url, map);

      log('Response from API: ${response.data}');

      if (response.data == null) {
        throw 'Invalid response';
      }

      if (response.data['success'] != true) {
        throw response.data['message'] ?? 'OTP verification failed';
      }

      final user = UserModel.fromJson(response.data);
      // logic.setUser(user);
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
}
