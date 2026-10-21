// lib/features/my_bids/presentation/logic/active_bids_notifier.dart

import 'package:dealer/features/live_auction/data/model/active_bid_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_active_bids_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_active_bids/my_bids_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveBidsNotifier
    extends StateNotifier<MyBidsState<ActiveBidsResponse>> {
  final GetActiveBidsUseCase getActiveBidsUseCase;

  ActiveBidsNotifier(this.getActiveBidsUseCase)
      : super(const MyBidsState.initial());

  Future<void> fetchActiveBids({int page = 1, int limit = 20}) async {
    state = const MyBidsState.loading();
    try {
      final res = await getActiveBidsUseCase();
      if (res.success) {
        state = MyBidsState.loaded(res);
      } else {
        state = MyBidsState.error(res.message ?? 'Failed to fetch active bids');
      }
    } catch (e) {
      state = MyBidsState.error(e.toString());
    }
  }
}
