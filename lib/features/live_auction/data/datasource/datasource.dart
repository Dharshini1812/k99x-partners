// lib/features/auction/data/datasource/auction_datasource.dart
import 'dart:developer';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';

import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';

import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuctionDatasource {
  Future<List<LiveAuctionModel>> getLiveAuctions(LiveAuctionParams params);

  /// `GET admin/live-auction/vehicles?status=...` — fetched on entry
  /// to the auctions screen and whenever the filter sheet's status
  /// changes, as a separate call from [getLiveAuctions] (which drives
  /// the existing date-ranged `auction-live/json` fetch).
  Future<List<LiveAuctionModel>> getLiveAuctionVehicles(
      LiveAuctionVehiclesParams params);

  Future<PlaceBidResponseModel> placeBid({
    required String vehicleId,
    required double bidAmount,
  });
  Future<VehicleDetailResponse> getVehicleDetail(String vehicleId);

  Future<AutoBidResponseModel> enableAutoBid({
    required String vehicleId,
    required double maxBidAmount,
  });
  Future<Response> getBidActivity(String vehicleId);
}

class AuctionDatasourceImpl implements AuctionDatasource {
  final Ref ref;
  AuctionDatasourceImpl(this.ref);

  @override
  Future<List<LiveAuctionModel>> getLiveAuctions(
    LiveAuctionParams params,
  ) async {
    try {
      final api = ref.read(apiService);

      final uri = Uri.parse(Url.liveAuctionUrl)
          .replace(queryParameters: params.toQueryParams());

      final response = await api.get1(uri.toString());

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> list = (data['vehicles'] as List<dynamic>?) ?? [];

      return list
          .map((e) => LiveAuctionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Get Live Auctions Error : $e");
      rethrow;
    }
  }

  @override
  Future<List<LiveAuctionModel>> getLiveAuctionVehicles(
    LiveAuctionVehiclesParams params,
  ) async {
    try {
      final api = ref.read(apiService);

      final uri = Uri.parse(Url.liveAuctionVehiclesUrl)
          .replace(queryParameters: params.toQueryParams());

      final response = await api.get1(uri.toString());

      final data = response.data as Map<String, dynamic>;
      // Same top-level shape as auction-live/json — {success, count,
      // vehicles: [...]} — so this reuses LiveAuctionModel as-is.
      final List<dynamic> list = (data['vehicles'] as List<dynamic>?) ?? [];

      return list
          .map((e) => LiveAuctionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Get Live Auction Vehicles Error : $e");
      rethrow;
    }
  }

  @override
  Future<PlaceBidResponseModel> placeBid({
    required String vehicleId,
    required double bidAmount,
  }) async {
    try {
      final api = ref.read(apiService);
      final response = await api.post1(
        '${Url.placeBidUrl}$vehicleId',
        {'bidAmount': bidAmount},
      );
      return PlaceBidResponseModel.fromJson(response.data);
    } catch (e) {
      log("Place Bid Error : $e");
      rethrow;
    }
  }

  @override
  Future<AutoBidResponseModel> enableAutoBid({
    required String vehicleId,
    required double maxBidAmount,
  }) async {
    try {
      final api = ref.read(apiService);
      final response = await api.post1(
        '${Url.autoBidUrl}$vehicleId',
        {'maxBidAmount': maxBidAmount},
      );
      return AutoBidResponseModel.fromJson(response.data);
    } catch (e) {
      log("Enable AutoBid Error : $e");
      rethrow;
    }
  }

  @override
  Future<Response> getBidActivity(String vehicleId) async {
    final api = ref.read(apiService);
    const url = Url.activityUrl;
    return await api.get1('$url$vehicleId');
  }

  @override
  Future<VehicleDetailResponse> getVehicleDetail(String vehicleId) async {
    final api = ref.read(apiService);
    const url = Url.vehicleDetailView;
    final response = await api.get1('$url$vehicleId');
    return VehicleDetailResponse.fromJson(response.data);
  }
}

// lib/features/live_auction/domain/usecase/live_auction_vehicles_params.dart

/// Params for `GET admin/live-auction/vehicles`. Only `status` is
/// confirmed working against the backend right now (from the sample
/// curl: `?status=LIVE`) — if the filter sheet needs to also narrow by
/// state/city/lender/category the way `LiveAuctionParams` does for the
/// existing `auction-live/json` endpoint, confirm with the backend
/// that this endpoint actually accepts those query params before
/// wiring them in here; they're not included yet since that isn't
/// confirmed.
class LiveAuctionVehiclesParams {
  final String status;

  const LiveAuctionVehiclesParams({required this.status});

  Map<String, dynamic> toQueryParams() {
    return {'status': status};
  }
}
