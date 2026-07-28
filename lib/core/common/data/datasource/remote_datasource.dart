import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
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
}

class CommonDatasourceimpl implements CommonDatasource {
  final Ref ref;
  CommonDatasourceimpl(this.ref);
  @override
  Future<List<StateModel>> getState() async {
    try {
      final api = ref.read(apiService);
      const url = Url.stateUrl;

      final data = await api.get2(url);
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

      final data = await api.get2(url);
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
}
