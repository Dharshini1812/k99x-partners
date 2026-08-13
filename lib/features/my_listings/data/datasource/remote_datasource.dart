import 'dart:developer';

import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:dealer/features/my_listings/data/model/kyc_submit_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ListingDataSource {
  Future<VehicleResponse> getMyListings({int? offset, int? limit});
  Future<VehicleResponse> getLiveListings({int? offset, int? limit});
  Future<KycSubmitResponse> addKyc(KycSubmitRequest? request);
}

class ListingDatasourceImpl implements ListingDataSource {
  final Ref ref;
  ListingDatasourceImpl(this.ref);
  @override
  Future<VehicleResponse> getMyListings({
    int? offset,
    int? limit,
  }) async {
    try {
      final api = ref.read(apiService);
      final response = await api.get2(
        "${Url.myStockUrl}?offset=$offset&limit=$limit",
      );

      return VehicleResponse.fromJson(response);
    } catch (e) {
      log("My Listing Error : $e");
      rethrow;
    }
  }

  @override
  Future<VehicleResponse> getLiveListings({
    int? offset,
    int? limit,
    LiveStockFilter? filter,
  }) async {
    try {
      final api = ref.read(apiService);
      final response =
          await api.get2("${Url.liveStockUrl}?offset=$offset&limit=$limit");
      return VehicleResponse.fromJson(response);
    } catch (e) {
      log("Live Listing Error : $e");
      rethrow;
    }
  }

  @override
  @override
  Future<KycSubmitResponse> addKyc(KycSubmitRequest? request) async {
    try {
      const url = Url.uploadKyc;
      final api = ref.read(apiService);

      final formData = await request?.toFormData();
      final response = await api.postMultipart(url, formData ?? FormData());

      // response is a Dio Response — the JSON body is in response.data,
      // not the Response object itself.
      return KycSubmitResponse.fromJson(response.data);
    } catch (e) {
      log("Add KYC Error : $e");
      rethrow;
    }
  }
}
