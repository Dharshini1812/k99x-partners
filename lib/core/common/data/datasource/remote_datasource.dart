import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/lender_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CommonDatasource {
  Future<List<StateModel>> getState();
  Future<List<CityModel>> getCity({String? id});
  Future<List<MakeModel>> getMake();
  Future<List<ModelModel>> getModel({required int makeId});
  Future<List<VariantModel>> getVariant({required int modelId});
  Future<RCDetailsModel> getRcDetails(String vehRegId);
  Future<List<LenderModel>> getLenderList();
}

class CommonDatasourceimpl implements CommonDatasource {
  final Ref ref;
  CommonDatasourceimpl(this.ref);

  @override
  Future<List<StateModel>> getState() async {
    try {
      final api = ref.read(apiService);
      const url = Url.stateUrl;

      // Was api.get2(url) — get2() calls getAuthHeaders(), which throws
      // "not authenticated" when there's no stored session. This runs
      // during signup, before an account exists, so it always failed
      // silently into GetStateState.error() here. State/city are plain
      // reference data (not personalized per dealer), so there's no
      // downside to fetching them without auth for everyone, logged in
      // or not — same reasoning as the register call and the
      // auction-listing fix from before.
      final response = await api.get(url);
      final data = response.data;
      if (data is List) {
        final result = data.map((e) => StateModel.fromJson(e)).toList();

        return result;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CityModel>> getCity({String? id}) async {
    try {
      final api = ref.read(apiService);
      final url = '${Url.cityUrl}$id';

      // Same fix as getState() above — was api.get2(url).
      final response = await api.get(url);
      final data = response.data;
      if (data is List) {
        final result = data.map((e) => CityModel.fromJson(e)).toList();

        return result;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MakeModel>> getMake() async {
    final api = ref.read(apiService);
    const url = Url.makeUrl;
    final data = await api.get2(url);

    if (data is List) {
      final result = data.map((e) => MakeModel.fromJson(e)).toList();
      debugPrint('DATASOURCE PARSED COUNT: ${result.length}'); // <-- check this
      return result;
    }
    if (data is Map<String, dynamic>) {
      return [MakeModel.fromJson(data)];
    }
    return [];
  }

  @override
  Future<List<ModelModel>> getModel({required int makeId}) async {
    final api = ref.read(apiService);
    final url = '${Url.modelUrl}$makeId';
    final data = await api.get2(url);
    if (data is List) {
      return data.map((e) => ModelModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<VariantModel>> getVariant({required int modelId}) async {
    final api = ref.read(apiService);
    final url = '${Url.variantsUrl}$modelId';
    final data = await api.get2(url);
    if (data is List) {
      return data.map((e) => VariantModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<RCDetailsModel> getRcDetails(String vehRegId) async {
    try {
      final api = ref.read(apiService);
      final url = '${Url.getRCDetails}$vehRegId';
      final data = await api.get2(url);
      return RCDetailsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<LenderModel>> getLenderList() async {
    try {
      final api = ref.read(apiService);
      const url = Url.lenderListUrl;
      final data = await api.get2(url);
      if (data is List) {
        return data.map((e) => LenderModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
