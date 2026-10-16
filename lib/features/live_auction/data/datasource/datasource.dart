// lib/features/auction/data/datasource/auction_datasource.dart
import 'dart:convert';
import 'dart:developer';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/live_auction/data/model/a_vehicle_detail.dart';
import 'package:dealer/features/live_auction/data/model/auto_bid_model.dart';
import 'package:dealer/features/live_auction/data/model/event_model.dart';
import 'package:dealer/features/live_auction/data/model/live_model.dart';
import 'package:dealer/features/live_auction/data/model/place_bid_model.dart';
import 'package:dealer/features/live_auction/data/model/watch_request_model.dart';
import 'package:dealer/features/live_auction/data/model/watch_response_model.dart';
import 'package:dealer/features/live_auction/domain/usecase/live_auction_params.dart';

import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String kTrialUserId = '193';

abstract class AuctionDatasource {
  Future<List<LiveAuctionModel>> getLiveAuctions(LiveAuctionParams params);
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
  Future<EventResponseModel> fetchEvents();
  Future<EventResponseModel> fetchUpcomingEvents();
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
  @override
  Future<PlaceBidResponseModel> placeBid({
    required String vehicleId,
    required double bidAmount,
  }) async {
    try {
      final api = ref.read(apiService);
      final response = await api.post1(
        '${Url.placeBidUrl}$vehicleId',
        {
          'bidAmount': bidAmount.toInt()
        }, // Convert to integer to avoid float representation
      );
      return PlaceBidResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // This logs the exact JSON or string reason returned by the server
      log("Place Bid Server Response Body: ${e.response?.data}");
      log("Place Bid Status Code: ${e.response?.statusCode}");
      rethrow;
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

  @override
  Future<EventResponseModel> fetchEvents() async {
    final api = ref.read(apiService);
    final response =
        await api.get1(Url.allEventsUrl); // Replace with your endpoint
    return EventResponseModel.fromJson(response.data);
  }

  @override
  Future<EventResponseModel> fetchUpcomingEvents() async {
    final api = ref.read(apiService);
    final response =
        await api.get1(Url.upcomingUrl); // Replace with your endpoint
    return EventResponseModel.fromJson(response.data);
  }
}

class LiveAuctionVehiclesParams {
  final String status;

  const LiveAuctionVehiclesParams({required this.status});

  Map<String, dynamic> toQueryParams() {
    return {'status': status};
  }
}
