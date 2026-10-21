// lib/features/my_bids/presentation/logic/bid_history_notifier.dart

import 'package:dealer/features/live_auction/data/model/bid_history_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_bid_history_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_active_bids/my_bids_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BidHistoryNotifier
    extends StateNotifier<MyBidsState<BidHistoryResponse>> {
  final GetBidHistoryUseCase getBidHistoryUseCase;

  BidHistoryNotifier(this.getBidHistoryUseCase)
      : super(const MyBidsState.initial());

  Future<void> fetchBidHistory({
    String? status,
    int? fromDate,
    int? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    state = const MyBidsState.loading();
    try {
      final res = await getBidHistoryUseCase();
      if (res.success) {
        state = MyBidsState.loaded(res);
      } else {
        state = MyBidsState.error(res.message ?? 'Failed to fetch bid history');
      }
    } catch (e) {
      state = MyBidsState.error(e.toString());
    }
  }
}
