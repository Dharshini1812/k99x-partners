// lib/features/auction/presentation/logic/live_auction/live_auction_provider.dart

import 'package:dealer/features/live_auction/data/datasource/datasource.dart';
import 'package:dealer/features/live_auction/data/repository/repository_impl.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';
import 'package:dealer/features/live_auction/domain/usecase/auction_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/auto_bid_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/bid_activity_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_detail_vehcile_usecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/get_live_uzecase.dart';
import 'package:dealer/features/live_auction/domain/usecase/place_bid_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction/live_auction_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/auction/live_auction_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/auto_bid/auto_bid_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/auto_bid/auto_bid_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/bid_activity/bid_activity_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/bid_activity/bid_activity_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_live/get_live_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_live/get_live_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/live_service_socket/live_bid_socket.notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/place_bid/place_bid_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/place_bid/place_bid_state.dart';
import 'package:dealer/features/live_auction/presentation/logic/vehicle_detail/vehicle_detail_notifier.dart';
import 'package:dealer/features/live_auction/presentation/logic/vehicle_detail/vehicle_detail_state.dart';
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
final liveBidSocketNotifierProvider = StateNotifierProvider.autoDispose<
    LiveBidSocketNotifier, LiveBidSocketState>((ref) {
  final useCase = ref.watch(bidActivityUseCaseProvider);
  return LiveBidSocketNotifier(useCase);
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
