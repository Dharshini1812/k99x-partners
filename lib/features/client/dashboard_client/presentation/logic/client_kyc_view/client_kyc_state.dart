// lib/features/client/presentation/logic/client_kyc_view_state.dart

import 'package:dealer/features/client/dashboard_client/data/model/kyc_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_kyc_state.freezed.dart';

@freezed
class ClientKycViewState with _$ClientKycViewState {
  const factory ClientKycViewState.initial() = _ClientKycViewInitial;
  const factory ClientKycViewState.loading() = _ClientKycViewLoading;
  const factory ClientKycViewState.data(ClientKycViewResponseModel data) =
      _ClientKycViewData;
  const factory ClientKycViewState.error(String msg) = _ClientKycViewError;
}
