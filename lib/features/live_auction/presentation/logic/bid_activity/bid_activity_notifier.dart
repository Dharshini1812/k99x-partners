// lib/features/live_auction/presentation/logic/bid_activity/bid_activity_notifier.dart

import 'dart:async';
import 'package:dealer/features/live_auction/domain/usecase/bid_activity_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/bid_activity/bid_activity_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BidActivityNotifier extends StateNotifier<BidActivityState> {
  final BidActivityUseCase _bidActivityUseCase;
  Timer? _pollingTimer;

  BidActivityNotifier(this._bidActivityUseCase)
      : super(const BidActivityState.initial());

  Future<void> fetchBidActivity(String vehicleId, {bool silent = false}) async {
    if (!silent) {
      state = const BidActivityState.loading();
    }

    final result = await _bidActivityUseCase(vehicleId);

    result.fold(
      (failure) {
        if (!silent) {
          state = BidActivityState.error(failure.msg ?? 'An error occurred');
        }
      },
      (data) {
        state = BidActivityState.data(data);
      },
    );
  }

  /// Start polling every 3 seconds while viewing the sheet
  void startPolling(String vehicleId,
      {Duration interval = const Duration(seconds: 3)}) {
    _pollingTimer?.cancel();
    // Immediate initial fetch
    fetchBidActivity(vehicleId, silent: false);

    _pollingTimer = Timer.periodic(interval, (_) {
      fetchBidActivity(vehicleId, silent: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
