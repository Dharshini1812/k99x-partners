// lib/features/live_auction/presentation/logic/live_auction_vehicles/live_auction_vehicles_notifier.dart

import 'package:dealer/features/live_auction/data/datasource/datasource.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_live_uzecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_live/get_live_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveAuctionVehiclesNotifier
    extends StateNotifier<LiveAuctionVehiclesState> {
  final GetLiveAuctionVehiclesUsecase getLiveAuctionVehiclesUsecase;

  LiveAuctionVehiclesNotifier({required this.getLiveAuctionVehiclesUsecase})
      : super(const LiveAuctionVehiclesState.initial());

  /// [status] should be one of the backend's expected values (e.g.
  /// 'LIVE', 'UPCOMING') — pass whatever the active tab / filter
  /// sheet's status resolves to, the same way AuctionLogic.search()
  /// resolves status for the existing auction-live/json fetch.
  Future<void> getLiveAuctionVehicles(String status) async {
    state = const LiveAuctionVehiclesState.loading();
    try {
      final vehicles = await getLiveAuctionVehiclesUsecase(
        LiveAuctionVehiclesParams(status: status),
      );
      state = LiveAuctionVehiclesState.data(vehicles);
    } catch (e) {
      state = LiveAuctionVehiclesState.error(e.toString());
    }
  }
}
