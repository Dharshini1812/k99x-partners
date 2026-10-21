// lib/features/auction/presentation/logic/live_auction/live_auction_provider.dart

import 'package:dealer/features/live_auction/data/datasource/datasource.dart';
import 'package:dealer/features/live_auction/data/model/active_bid_model.dart';
import 'package:dealer/features/live_auction/data/model/bid_history_model.dart';
import 'package:dealer/features/live_auction/data/repository/repository_impl.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';
import 'package:dealer/features/live_auction/domain/usecase/auction_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/auto_bid_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/bid_activity_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_active_bids_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_bid_history_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_detail_vehcile_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_event_vehicles_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_events_usecae.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_live_uzecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_upcoming_events_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/place_bid_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/watch_add_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/watch_fetch_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction/live_auction_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction/live_auction_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/auto_bid/auto_bid_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/auto_bid/auto_bid_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/bid_activity/bid_activity_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/bid_activity/bid_activity_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_active_bids/active_bids_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_active_bids/bid_history_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_active_bids/my_bids_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_event_vehicles/event_vehicle_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_event_vehicles/event_vehicles_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_events/get_events_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_events/get_events_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_live/get_live_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_live/get_live_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_upcoming_events/get_up_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_upcoming_events/get_up_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/live_service_socket/live_bid_socket.notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/place_bid/place_bid_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/place_bid/place_bid_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/vehicle_detail/vehicle_detail_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/vehicle_detail/vehicle_detail_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/watchlist_add/watch_add_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/watchlist_add/watchlist_update_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/watchlist_fetch/watch_get_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/watchlist_fetch/watchlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _auctionDatasource =
    Provider<AuctionDatasource>((ref) => AuctionDatasourceImpl(ref));

final _auctionRepository = Provider<AuctionRepository>(
  (ref) => AuctionRepositoryImpl(datasource: ref.read(_auctionDatasource)),
);

final _getLiveAuctionUsecase = Provider<GetLiveAuctionUsecase>(
  (ref) =>
      GetLiveAuctionUsecase(auctionRepository: ref.read(_auctionRepository)),
);

final liveAuctionNotifier =
    StateNotifierProvider<LiveAuctionNotifier, LiveAuctionState>(
  (ref) => LiveAuctionNotifier(
    getLiveAuctionUsecase: ref.read(_getLiveAuctionUsecase),
  ),
);
final _placeBidUsecase = Provider<PlaceBidUsecase>(
  (ref) => PlaceBidUsecase(bidRepository: ref.read(_auctionRepository)),
);

final _enableAutoBidUsecase = Provider<EnableAutoBidUsecase>(
  (ref) => EnableAutoBidUsecase(bidRepository: ref.read(_auctionRepository)),
);

final placeBidNotifier = StateNotifierProvider<PlaceBidNotifier, PlaceBidState>(
  (ref) => PlaceBidNotifier(placeBidUsecase: ref.read(_placeBidUsecase)),
);

final autoBidNotifier = StateNotifierProvider<AutoBidNotifier, AutoBidState>(
  (ref) =>
      AutoBidNotifier(enableAutoBidUsecase: ref.read(_enableAutoBidUsecase)),
);
// 1. UseCase Provider
final bidActivityUseCaseProvider = Provider<BidActivityUseCase>((ref) {
  final repository = ref.watch(_auctionRepository);
  return BidActivityUseCase(repository);
});

// 2. StateNotifier Provider
final bidActivityNotifierProvider =
    StateNotifierProvider.autoDispose<BidActivityNotifier, BidActivityState>(
        (ref) {
  final useCase = ref.watch(bidActivityUseCaseProvider);
  return BidActivityNotifier(useCase);
});
final liveBidSocketProvider = Provider<LiveBidSocketNotifier>((ref) {
  final socket = LiveBidSocketNotifier();
  ref.onDispose(() => socket.dispose());
  return socket;
});
// 1. Use case provider (injected with repository)
final getVehicleDetailUseCaseProvider =
    Provider<GetVehicleDetailUseCase>((ref) {
  final repository = ref.watch(_auctionRepository);
  return GetVehicleDetailUseCase(repository);
});

// 2. StateNotifier provider (use .autoDispose if page should clear on exit)
final vehicleDetailProvider = StateNotifierProvider.autoDispose<
    VehicleDetailNotifier, VehicleDetailState>((ref) {
  final useCase = ref.watch(getVehicleDetailUseCaseProvider);
  return VehicleDetailNotifier(useCase);
});
final _getLiveAuctionVehiclesUsecase = Provider<GetLiveAuctionVehiclesUsecase>(
  (ref) => GetLiveAuctionVehiclesUsecase(
      auctionRepository: ref.read(_auctionRepository)),
);

final liveAuctionVehiclesNotifier = StateNotifierProvider.family<
    LiveAuctionVehiclesNotifier, LiveAuctionVehiclesState, String>(
  (ref, status) => LiveAuctionVehiclesNotifier(
    getLiveAuctionVehiclesUsecase: ref.read(_getLiveAuctionVehiclesUsecase),
  )..getLiveAuctionVehicles(status),
);

// UseCases
final getWatchlistUseCaseProvider = Provider<GetWatchlistUseCase>((ref) {
  final repo = ref.watch(_auctionRepository);
  return GetWatchlistUseCase(repository: repo);
});

final updateWatchlistUseCaseProvider = Provider<UpdateWatchlistUseCase>((ref) {
  final repo = ref.watch(_auctionRepository);
  return UpdateWatchlistUseCase(repository: repo);
});

// Separate Notifiers:
// 1. Fetch/List Provider
final watchlistNotifierProvider =
    StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
  return WatchlistNotifier(
    getWatchlistUseCase: ref.watch(getWatchlistUseCaseProvider),
  );
});

// 2. Add/Update Provider
final watchlistUpdateNotifierProvider =
    StateNotifierProvider<WatchlistUpdateNotifier, WatchlistUpdateState>((ref) {
  return WatchlistUpdateNotifier(
    updateWatchlistUseCase: ref.watch(updateWatchlistUseCaseProvider),
    ref: ref,
  );
});

//events-live

final _eventUsecase = Provider<GetEventsUseCase>(
  (ref) => GetEventsUseCase(
    repository: ref.read(_auctionRepository),
  ),
);

final eventProvider = StateNotifierProvider<LiveEventsNotifier, LiveEventState>(
  (ref) => LiveEventsNotifier(
    getEventsUseCase: ref.read(_eventUsecase),
  ),
);

//upcoming-event
final _upeventUsecase = Provider<GetUpcomingEventUseCase>(
  (ref) => GetUpcomingEventUseCase(
    repository: ref.read(_auctionRepository),
  ),
);

final eventUpProvider =
    StateNotifierProvider<UpcomingEventsNotifier, UpcomingEventState>(
  (ref) => UpcomingEventsNotifier(
    getEventsUseCase: ref.read(_upeventUsecase),
  ),
);

//event-vehicles provider

final _getEventVehiclesUseCaseProvider =
    Provider<GetEventVehiclesUseCase>((ref) {
  final repository = ref.watch(_auctionRepository);
  return GetEventVehiclesUseCase(repository);
});

final eventVehiclesNotifierProvider =
    StateNotifierProvider<EventVehiclesNotifier, EventVehiclesState>((ref) {
  final useCase = ref.watch(_getEventVehiclesUseCaseProvider);
  return EventVehiclesNotifier(useCase);
});

//history

final _getActiveBidsUseCaseProvider = Provider<GetActiveBidsUseCase>((ref) {
  final repo = ref.read(_auctionRepository);
  return GetActiveBidsUseCase(repo);
});

final _getBidHistoryUseCaseProvider = Provider<GetBidHistoryUseCase>((ref) {
  final repo = ref.read(_auctionRepository);
  return GetBidHistoryUseCase(repo);
});
final activeBidsNotifierProvider =
    StateNotifierProvider<ActiveBidsNotifier, MyBidsState<ActiveBidsResponse>>(
        (ref) {
  final useCase = ref.read(_getActiveBidsUseCaseProvider);
  return ActiveBidsNotifier(useCase);
});

final bidHistoryNotifierProvider =
    StateNotifierProvider<BidHistoryNotifier, MyBidsState<BidHistoryResponse>>(
        (ref) {
  final useCase = ref.read(_getBidHistoryUseCaseProvider);
  return BidHistoryNotifier(useCase);
});
