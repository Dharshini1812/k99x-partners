import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_bid_state.freezed.dart';

@freezed
class PlaceBidState with _$PlaceBidState {
  const factory PlaceBidState.initial() = _PlaceBidStateInitial;
  const factory PlaceBidState.loading() = _PlaceBidStateLoading;
  const factory PlaceBidState.data(PlaceBidResponseModel data) =
      _PlaceBidStateData;
  const factory PlaceBidState.error(String msg) = _PlaceBidStateError;
}
