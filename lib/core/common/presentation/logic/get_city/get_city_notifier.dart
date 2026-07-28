import 'package:dealer/core/common/domain/usecase/get_city.dart';
import 'package:dealer/core/common/presentation/logic/get_city/get_city_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetCityNotifier extends StateNotifier<GetCityState> {
  final GetCityUsecase _getStateState;

  GetCityNotifier(
      {required GetCityUsecase getStateState, GetCityState? initialState})
      : _getStateState = getStateState,
        super(initialState ?? const GetCityState.initial());
  getCity({String? id}) async {
    state = const GetCityState.loading();
    try {
      final data = await _getStateState.getCity(id: id);
      data.fold((l) {
        state = const GetCityState.loading();
      }, (r) {
        state = GetCityState.data(r);
      });
    } catch (e) {
      state = GetCityState.error(e.toString());
    }
  }
}
