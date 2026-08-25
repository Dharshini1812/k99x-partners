// lib/features/client/presentation/logic/client_kyc_view_notifier.dart
import 'package:dealer/features/client/dashboard_client/domain/usecase/client_kyc_view.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/client_kyc_view/client_kyc_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientKycViewNotifier extends StateNotifier<ClientKycViewState> {
  final GetClientKycView _usecase;

  ClientKycViewNotifier({required GetClientKycView usecase})
      : _usecase = usecase,
        super(const ClientKycViewState.initial());

  Future<void> fetch(String vehicleId) async {
    state = const ClientKycViewState.loading();

    final result = await _usecase(vehicleId);

    result.fold(
      (failure) {
        state = ClientKycViewState.error(
            failure.msg ?? 'Could not load KYC details');
      },
      (response) {
        state = ClientKycViewState.data(response);
      },
    );
  }
}
