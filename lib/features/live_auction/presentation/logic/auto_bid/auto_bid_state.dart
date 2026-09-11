import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auto_bid_state.freezed.dart';

@freezed
class AutoBidState with _$AutoBidState {
  const factory AutoBidState.initial() = _AutoBidStateInitial;
  const factory AutoBidState.loading() = _AutoBidStateLoading;
  const factory AutoBidState.data(AutoBidResponseModel data) =
      _AutoBidStateData;
  const factory AutoBidState.error(String msg) = _AutoBidStateError;
}
