// lib/features/auction/data/datasource/auction_datasource.dart
import 'dart:convert';
import 'dart:developer';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';

import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:dealer/features/live_auction/data/model/watch_request_model.dart';
import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';

import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Static placeholder user ID sent on trial/guest requests, since the
/// backend expects X-USER-ID on these endpoints even without Basic-Auth.
/// This is a fixed ID standing in for "no real dealer account yet" —
/// confirm with the backend that 193 is the intended guest/trial
/// account id and not just a value that happened not to error.
const String kTrialUserId = '193';

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
  Future<WatchlistFetchResponseModel> getWatchlist();

  Future<WatchlistUpdateResponseModel> updateWatchlist(
      WatchlistUpdateRequestModel request);
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

      // Only a trial/guest session (no stored credentials to send)
      // skips Basic-Auth here. A real logged-in dealer keeps hitting
      // get1() exactly as before — unchanged for the normal
      // login/signup flow, since that's what returns this dealer's own
      // bid/status fields personalized to their account. get1() would
      // throw "not authenticated" before the request even goes out for
      // a guest with no stored session, which is the case this branch
      // exists for — confirmed via a direct API-tool call (X-API-KEY
      // only, no Basic-Auth) that the backend still returns real
      // listings without one.
      final isTrial = ref.read(trialLogic).isTrialSession;
      final response = isTrial
          ? await api.get(uri.toString(), headers: {'X-USER-ID': kTrialUserId})
          : await api.get1(uri.toString());

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

      // NOT verified the same way as getLiveAuctions above — only
      // Url.liveAuctionUrl (auction-live/json) was confirmed to work
      // with X-API-KEY alone. If this /vehicles endpoint also needs no
      // Basic-Auth, switch this to api.get(...) too; until then it
      // stays authenticated, meaning a trial guest hitting whichever
      // screen calls getLiveAuctionVehicles will still fail here even
      // though getLiveAuctions above now succeeds for them.
      final response = await api.get1(uri.toString());
      final data = response.data as Map<String, dynamic>;
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

    // Same reasoning as getLiveAuctions above: a trial/guest session has
    // no stored credentials, so get1() throws "not authenticated" before
    // the request even leaves the device. Unlike getLiveAuctions, this
    // specific endpoint has NOT been independently confirmed to accept
    // X-API-KEY alone (no Basic-Auth) — branching it the same way is the
    // fix for the screenshot error, but confirm against the backend (or
    // via a direct API-tool call) that vehicleDetailView actually
    // returns data for a guest before relying on this in production.
    final isTrial = ref.read(trialLogic).isTrialSession;
    final response = isTrial
        ? await api.get('$url$vehicleId', headers: {'X-USER-ID': kTrialUserId})
        : await api.get1('$url$vehicleId');

    return VehicleDetailResponse.fromJson(response.data);
  }

  @override
  Future<WatchlistFetchResponseModel> getWatchlist() async {
    final api = ref.read(apiService);
    final response = await api.get1(Url.watchListUrl);

    // Extract the body payload from the Dio Response
    final rawData = response.data;

    final Map<String, dynamic> map = rawData is String
        ? jsonDecode(rawData) as Map<String, dynamic>
        : Map<String, dynamic>.from(rawData as Map);

    return WatchlistFetchResponseModel.fromJson(map);
  }

  @override
  @override
  Future<WatchlistUpdateResponseModel> updateWatchlist(
      WatchlistUpdateRequestModel request) async {
    final api = ref.read(apiService);

    // POST with body data matching the curl --data payload[cite: 6]
    final response = await api.post1(
      Url.watchAddUrl,
      request.toJson(),
    );

    final rawData = response.data;
    final Map<String, dynamic> map = rawData is String
        ? jsonDecode(rawData) as Map<String, dynamic>
        : Map<String, dynamic>.from(rawData as Map);

    return WatchlistUpdateResponseModel.fromJson(map);
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
