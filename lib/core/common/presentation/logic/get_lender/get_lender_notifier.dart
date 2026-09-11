import 'package:dealer/core/common/domain/usecase/get_lender.dart';
import 'package:dealer/core/common/presentation/logic/get_lender/get_lender_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetLenderNotifier extends StateNotifier<GetLenderState> {
  final GetLenderUsecase _getLendorState;

  GetLenderNotifier(
      {required GetLenderUsecase getStateState, GetLenderState? initialState})
      : _getLendorState = getStateState,
        super(initialState ?? const GetLenderState.initial());
  getLender() async {
    state = const GetLenderState.loading();
    try {
      final data = await _getLendorState.call();
      data.fold((l) {
        state = const GetLenderState.loading();
      }, (r) {
        state = GetLenderState.data(r);
      });
    } catch (e) {
      state = GetLenderState.error(e.toString());
    }
  }
}
