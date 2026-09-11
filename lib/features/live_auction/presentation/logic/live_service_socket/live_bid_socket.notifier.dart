import 'package:dealer/core/services/auction_socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/bid_activity_usecase.dart';

class LiveBidSocketState {
  final bool isConnected;
  final BidActivityData? activity;
  final String? error;

  const LiveBidSocketState({
    this.isConnected = false,
    this.activity,
    this.error,
  });

  LiveBidSocketState copyWith({
    bool? isConnected,
    BidActivityData? activity,
    String? error,
  }) {
    return LiveBidSocketState(
      isConnected: isConnected ?? this.isConnected,
      activity: activity ?? this.activity,
      error: error ?? this.error,
    );
  }
}

class LiveBidSocketNotifier extends StateNotifier<LiveBidSocketState> {
  final BidActivityUseCase _activityUseCase;
  AuctionSocketService? _socketService;

  LiveBidSocketNotifier(this._activityUseCase)
      : super(const LiveBidSocketState());

  Future<void> init(String vehicleId) async {
    // 1. Initial snapshot via HTTP REST
    final result = await _activityUseCase(vehicleId);
    result.fold(
      (failure) => state = state.copyWith(error: failure.msg),
      (data) => state = state.copyWith(activity: data),
    );

    // 2. Connect WebSocket for live updates
    _socketService = AuctionSocketService();
    _socketService?.connectAndSubscribe(
      vehicleId: vehicleId,
      onActivityReceived: (data) {
        state = state.copyWith(
          isConnected: true,
          activity: data,
        );
      },
      onError: (err) {
        state = state.copyWith(error: err.toString());
      },
    );
  }

  @override
  void dispose() {
    _socketService?.disconnect();
    super.dispose();
  }
}
