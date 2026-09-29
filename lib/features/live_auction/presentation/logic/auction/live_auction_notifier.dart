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

  // Monotonically increasing token identifying the most recently
  // ISSUED getLiveAuctions() call — not the most recently RESOLVED one.
  //
  // AuctionHomePage.initState() can call search() (which calls this)
  // multiple times back-to-back with different params: once directly
  // with no filters, then again once the dealer's default state loads
  // (now with stateId set), then again if the dashboard listener fires
  // separately. Network responses are not guaranteed to arrive in the
  // same order the requests were sent — a network hiccup, retry, or
  // just normal timing variance can make an OLDER, broader/unfiltered
  // request resolve AFTER a NEWER, correctly-filtered one.
  //
  // Without this guard, whichever response simply happens to *land*
  // last wins, silently overwriting a more current, correct result —
  // this was the actual root cause of "reload shows No live auctions
  // found" even though the account genuinely has LIVE vehicles: the
  // unfiltered launch call was clobbering the state-filtered call
  // moments after it had already populated the correct data.
  //
  // The fix: every call captures its own id when it STARTS. When a
  // call finishes, it only applies its result if its id still matches
  // the latest — i.e. no newer call was issued while it was in flight.
  // If a newer call has since started, this one's result (whatever it
  // is — data or error) is silently discarded, since something more
  // current already superseded it.
  int _requestId = 0;

  Future<void> getLiveAuctions(LiveAuctionParams params) async {
    final int requestId = ++_requestId;
    state = const LiveAuctionState.loading();
    try {
      final result = await getLiveAuctionUsecase.call(params);
      if (requestId != _requestId) {
        // A newer getLiveAuctions() call was issued while this one was
        // still in flight — this result is stale, discard it.
        return;
      }
      state = LiveAuctionState.data(result);
    } catch (e) {
      if (requestId != _requestId) return; // stale error, discard too
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
