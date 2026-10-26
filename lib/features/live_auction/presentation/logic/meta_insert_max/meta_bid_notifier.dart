// lib/features/meta_bid/presentation/logic/meta_bid_notifier.dart

import 'package:dealer/features/live_auction/data/model/meta_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/meta_insert_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/meta_maxbid_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/meta_insert_max/meta_bid_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MetaBidParam = ({String eventId, String itemId});

class MetaHighestBidNotifier extends StateNotifier<MetaHighestBidState> {
  final GetMetaHighestBidUseCase getHighestBidUseCase;

  MetaHighestBidNotifier(this.getHighestBidUseCase)
      : super(const MetaHighestBidState.initial());

  Future<void> fetchHighestBid({
    required String eventId,
    required String loanNo,
  }) async {
    state = const MetaHighestBidState.loading();

    try {
      final res = await getHighestBidUseCase(
        eventId: eventId,
        loanNo: loanNo,
      );

      if (res.success && res.data != null) {
        state = MetaHighestBidState.loaded(res.data!);
      } else {
        state = MetaHighestBidState.error(
          res.message.isNotEmpty ? res.message : 'Failed to fetch highest bid',
        );
      }
    } catch (e) {
      state = MetaHighestBidState.error(e.toString());
    }
  }
}

class InsertMetaBidNotifier extends StateNotifier<InsertMetaBidState> {
  final InsertMetaBidUseCase insertBidUseCase;

  InsertMetaBidNotifier(this.insertBidUseCase)
      : super(const InsertMetaBidState.initial());

  Future<bool> submitBid(InsertMetaBidRequestModel request) async {
    state = const InsertMetaBidState.submitting();

    try {
      final res = await insertBidUseCase(request);

      if (res.success && res.data != null) {
        state = InsertMetaBidState.success(
          res.data!,
          res.message.isNotEmpty
              ? res.message
              : 'Your bid has been recorded successfully!',
        );
        return true;
      } else {
        state = InsertMetaBidState.error(
          res.message.isNotEmpty ? res.message : 'Bid submission failed',
        );
        return false;
      }
    } catch (e) {
      state = InsertMetaBidState.error(e.toString());
      return false;
    }
  }

  void reset() {
    state = const InsertMetaBidState.initial();
  }
}

final metaHighestBidFamilyProvider = StateNotifierProvider.autoDispose
    .family<MetaHighestBidNotifier, MetaHighestBidState, MetaBidParam>(
  (ref, param) {
    final notifier =
        MetaHighestBidNotifier(ref.read(getMetaHighestBidUseCaseProvider));
    notifier.fetchHighestBid(
      eventId: param.eventId,
      loanNo: param.itemId,
    );
    return notifier;
  },
);
