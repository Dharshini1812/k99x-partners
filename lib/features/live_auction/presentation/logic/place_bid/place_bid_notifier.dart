// lib/features/live_auction/presentation/logic/bid/place_bid_notifier.dart

import 'package:dealer/features/live_auction/domain/usecase/place_bid_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/place_bid/place_bid_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaceBidNotifier extends StateNotifier<PlaceBidState> {
  final PlaceBidUsecase placeBidUsecase;
  PlaceBidNotifier({required this.placeBidUsecase})
      : super(const PlaceBidState.initial());

  Future<void> placeBid(
      {required String vehicleId, required double bidAmount}) async {
    state = const PlaceBidState.loading();
    try {
      final result = await placeBidUsecase.call(
          vehicleId: vehicleId, bidAmount: bidAmount);
      if (result.success) {
        state = PlaceBidState.data(result);
      } else {
        state = PlaceBidState.error(
            result.message.isNotEmpty ? result.message : 'Bid failed');
      }
    } catch (e) {
      state = PlaceBidState.error(e.toString());
    }
  }

  void reset() => state = const PlaceBidState.initial();
}
