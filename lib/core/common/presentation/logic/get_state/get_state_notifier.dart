import 'package:dealer/core/common/domain/usecase/get_state.dart';
import 'package:dealer/core/common/presentation/logic/get_state/get_state_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetStateNotifier extends StateNotifier<GetStateState> {
  final GetStatesUsecase _getStateState;

  GetStateNotifier(
      {required GetStatesUsecase getStateState, GetStateState? initialState})
      : _getStateState = getStateState,
        super(initialState ?? const GetStateState.initial());
  getState() async {
    state = const GetStateState.loading();
    try {
      final data = await _getStateState.getStates();
      data.fold((l) {
        state = const GetStateState.loading();
      }, (r) {
        state = GetStateState.data(r);
      });
    } catch (e) {
      state = GetStateState.error(e.toString());
    }
  }
}
