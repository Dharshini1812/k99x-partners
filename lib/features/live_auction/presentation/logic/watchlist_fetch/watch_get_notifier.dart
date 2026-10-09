import 'package:dealer/features/live_auction/domain/usecase/watch_fetch_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/watchlist_fetch/watchlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final GetWatchlistUseCase getWatchlistUseCase;

  WatchlistNotifier({required this.getWatchlistUseCase})
      : super(const WatchlistState.initial());

  Future<void> fetchWatchlist() async {
    state = const WatchlistState.loading();
    try {
      final res = await getWatchlistUseCase();
      final vehicles = res.data?.vehicles ?? [];
      state = WatchlistState.data(vehicles);
    } catch (e) {
      state = WatchlistState.error(e.toString());
    }
  }
}
