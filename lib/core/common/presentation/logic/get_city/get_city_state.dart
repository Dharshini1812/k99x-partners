import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'get_city_state.freezed.dart';

@freezed
class GetCityState with _$GetCityState {
  const factory GetCityState.initial() = _GetCityStateInitial;
  const factory GetCityState.loading() = _GetCityStateLoading;
  const factory GetCityState.data(List<CityModel> data) = _GetCityStateData;
  const factory GetCityState.error(String msg) = _GetCityStateError;
}
