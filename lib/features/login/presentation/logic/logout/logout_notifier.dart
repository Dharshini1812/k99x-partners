// lib/features/login/presentation/logic/logout_notifier.dart

import 'package:dealer/core/helper/storage_helper.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/login/domain/usecase/logout.dart';
import 'package:dealer/features/login/presentation/logic/logout/logout_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutNotifier extends StateNotifier<LogoutState> {
  final Logout _usecase;
  final Ref ref;

  LogoutNotifier({required Logout usecase, required this.ref})
      : _usecase = usecase,
        super(const LogoutState.initial());
  Future<bool> logout() async {
    state = const LogoutState.loading();

    try {
      final result = await _usecase();

      result.fold(
        (failure) {
          state = LogoutState.error(failure.msg ?? 'Logout request failed');
        },
        (response) {
          state = LogoutState.data(response);
        },
      );
    } catch (e) {
      state = LogoutState.error(e.toString());
    }

    final storage = SecureStorageService();
    await storage.logout();
    ref.read(bottomNavIndexProvider.notifier).state = 0;
    // ADAPT: see note above if this doesn't exist

    return true;
  }
}
