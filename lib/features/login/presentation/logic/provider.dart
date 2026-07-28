import 'package:dealer/core/services/api_service.dart';
import 'package:dealer/core/services/route_service.dart';
import 'package:dealer/features/login/data/datasource/remote_datasource.dart';
import 'package:dealer/features/login/data/repository/repository_impl.dart';
import 'package:dealer/features/login/domain/repository/repository.dart';
import 'package:dealer/features/login/domain/usecase/send_otp.dart';
import 'package:dealer/features/login/domain/usecase/verify_otp.dart';
import 'package:dealer/features/login/presentation/logic/send_otp/send_notifier.dart';
import 'package:dealer/features/login/presentation/logic/send_otp/send_state.dart';
import 'package:dealer/features/login/presentation/logic/verify_otp/verify_notifier.dart';
import 'package:dealer/features/login/presentation/logic/verify_otp/verify_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//--------Apiservice---------
final apiService = Provider<ApiService>((ref) => ApiServiceImpl(ref));

final routeService = Provider<RouteService>((ref) => RouteServiceImpl());

//sendOtp
final _loginRemoteDataSource =
    Provider<LoginRemoteDataSource>((ref) => LoginRemoteDataSourceImpl(ref));
final _repository = Provider<LoginRepository>(
    (ref) => LoginRepositoryImpl(ref.read(_loginRemoteDataSource)));

//Usecase-sendOtp
final _sendOtp =
    Provider<SendOtpUsecase>((ref) => SendOtpUsecase(ref.read(_repository)));
//Usecase-verifyOtp
final _verifyOtp = Provider<VerifyOtpUsecase>(
    (ref) => VerifyOtpUsecase(ref.read(_repository)));

//provider-sendotp
final sendOtpProvider = StateNotifierProvider<SendOtpNotifier, SendOtpState>(
    (ref) => SendOtpNotifier(usecase: ref.read(_sendOtp)));

//provider-verifyOtp
final verifyOtpProvider =
    StateNotifierProvider<VerifyOtpNotifier, VerifyOtpState>(
        (ref) => VerifyOtpNotifier(usecase: ref.read(_verifyOtp)));

final loginPhoneProvider = StateProvider<String>((ref) => '');
