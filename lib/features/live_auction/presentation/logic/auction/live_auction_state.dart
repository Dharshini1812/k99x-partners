// lib/features/auction/presentation/logic/live_auction/live_auction_state.dart

import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_auction_state.freezed.dart';

@freezed
class LiveAuctionState with _$LiveAuctionState {
  const factory LiveAuctionState.initial() = _LiveAuctionStateInitial;
  const factory LiveAuctionState.loading() = _LiveAuctionStateLoading;
  const factory LiveAuctionState.data(List<LiveAuctionModel> data) =
      _LiveAuctionStateData;
  const factory LiveAuctionState.error(String msg) = _LiveAuctionStateError;
}
