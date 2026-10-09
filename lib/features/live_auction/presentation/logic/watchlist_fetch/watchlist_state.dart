import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'watchlist_state.freezed.dart';

@freezed
class WatchlistState with _$WatchlistState {
  const factory WatchlistState.initial() = _WatchlistStateInitial;
  const factory WatchlistState.loading() = _WatchlistStateLoading;
  const factory WatchlistState.data(List<WatchlistVehicleItem> data) =
      _WatchlistStateData;
  const factory WatchlistState.error(String msg) = _WatchlistStateError;
}
