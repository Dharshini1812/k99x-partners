// lib/features/auction/presentation/logic/live_auction/live_auction_notifier.dart

import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/auction_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction/live_auction_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveAuctionNotifier extends StateNotifier<LiveAuctionState> {
  final GetLiveAuctionUsecase getLiveAuctionUsecase;

  LiveAuctionNotifier({required this.getLiveAuctionUsecase})
      : super(const LiveAuctionState.initial());

  Future<void> getLiveAuctions(LiveAuctionParams params) async {
    state = const LiveAuctionState.loading();
    try {
      final result = await getLiveAuctionUsecase.call(params);
      state = LiveAuctionState.data(result);
    } catch (e) {
      state = LiveAuctionState.error(e.toString());
    }
  }

  void updateVehicleBidLocally({
    required String vehicleId,
    required double newBidAmount,
    int? dealerId,
    bool isAutoBid = false,
  }) {
    state.maybeWhen(
      data: (vehicles) {
        final updatedList = vehicles.map((v) {
          if (v.vehicleId == vehicleId) {
            final currentBids = List<BidsModel>.from(v.bids ?? const []);

            // Create new bid entry matching your BidsModel
            final newBid = BidsModel(
              amount: newBidAmount,
              dealerId: dealerId,
              isAutoBid: isAutoBid,
              vehicleId: vehicleId,
              timestamp: DateTime.now().toIso8601String(),
            );

            // Prepend new top bid
            currentBids.insert(0, newBid);

            return v.copyWith(bids: currentBids);
          }
          return v;
        }).toList();

        state = LiveAuctionState.data(updatedList);
      },
      orElse: () {},
    );
  }
}
