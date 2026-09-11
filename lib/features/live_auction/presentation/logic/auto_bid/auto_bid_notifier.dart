import 'package:dealer/features/live_auction/domain/usecase/auto_bid_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/auto_bid/auto_bid_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoBidNotifier extends StateNotifier<AutoBidState> {
  final EnableAutoBidUsecase enableAutoBidUsecase;
  AutoBidNotifier({required this.enableAutoBidUsecase})
      : super(const AutoBidState.initial());

  Future<void> enableAutoBid(
      {required String vehicleId, required double maxBidAmount}) async {
    state = const AutoBidState.loading();
    try {
      final result = await enableAutoBidUsecase.call(
          vehicleId: vehicleId, maxBidAmount: maxBidAmount);
      if (result.success) {
        state = AutoBidState.data(result);
      } else {
        state = AutoBidState.error(
            result.message.isNotEmpty ? result.message : 'AutoBid failed');
      }
    } catch (e) {
      state = AutoBidState.error(e.toString());
    }
  }

  void reset() => state = const AutoBidState.initial();
}
