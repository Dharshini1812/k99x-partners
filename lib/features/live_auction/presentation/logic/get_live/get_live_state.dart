// lib/features/live_auction/presentation/logic/live_auction_vehicles/live_auction_vehicles_state.dart

import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_live_state.freezed.dart';

@freezed
class LiveAuctionVehiclesState with _$LiveAuctionVehiclesState {
  const factory LiveAuctionVehiclesState.initial() =
      _LiveAuctionVehiclesStateInitial;
  const factory LiveAuctionVehiclesState.loading() =
      _LiveAuctionVehiclesStateLoading;
  const factory LiveAuctionVehiclesState.data(List<LiveAuctionModel> vehicles) =
      _LiveAuctionVehiclesStateData;
  const factory LiveAuctionVehiclesState.error(String msg) =
      _LiveAuctionVehiclesStateError;
}
