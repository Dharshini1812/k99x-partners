// lib/features/live_auction/presentation/logic/bid_activity/bid_activity_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';

part 'bid_activity_state.freezed.dart';

@freezed
class BidActivityState with _$BidActivityState {
  const factory BidActivityState.initial() = _Initial;
  const factory BidActivityState.loading() = _Loading;
  const factory BidActivityState.data(BidActivityData data) = _Data;
  const factory BidActivityState.error(String message) = _Error;
}
