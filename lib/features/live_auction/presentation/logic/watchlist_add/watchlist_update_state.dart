import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'watchlist_update_state.freezed.dart';

@freezed
class WatchlistUpdateState with _$WatchlistUpdateState {
  const factory WatchlistUpdateState.initial() = _WatchlistUpdateStateInitial;
  const factory WatchlistUpdateState.loading() = _WatchlistUpdateStateLoading;
  const factory WatchlistUpdateState.data(WatchlistUpdateResponseModel data) =
      _WatchlistUpdateStateData;
  const factory WatchlistUpdateState.error(String msg) =
      _WatchlistUpdateStateError;
}
