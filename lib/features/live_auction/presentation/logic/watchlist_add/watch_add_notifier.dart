import 'package:dealer/features/live_auction/data/model/watch_request_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/watch_add_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/provider.dart';
import 'package:dealer/features/live_auction/presentation/logic/watchlist_add/watchlist_update_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistUpdateNotifier extends StateNotifier<WatchlistUpdateState> {
  final UpdateWatchlistUseCase updateWatchlistUseCase;
  final Ref ref;

  WatchlistUpdateNotifier({
    required this.updateWatchlistUseCase,
    required this.ref,
  }) : super(const WatchlistUpdateState.initial());

  Future<bool> updateWatchlist({
    required String vehicleId,
    required bool add,
  }) async {
    state = const WatchlistUpdateState.loading();
    try {
      final request = WatchlistUpdateRequestModel(
        vehicleId: vehicleId,
        watchlist: add ? 1 : 0,
      );
      final res = await updateWatchlistUseCase(request);
      state = WatchlistUpdateState.data(res);

      if (res.success == true) {
        // Automatically refresh the list notifier
        ref.read(watchlistNotifierProvider.notifier).fetchWatchlist();
        return true;
      }
      return false;
    } catch (e) {
      state = WatchlistUpdateState.error(e.toString());
      return false;
    }
  }
}
