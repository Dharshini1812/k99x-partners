import 'package:dealer/core/common/domain/usecase/get_make.dart';
import 'package:dealer/core/common/presentation/logic/get_make/getmake_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetMakeNotifier extends StateNotifier<GetMakeState> {
  final GetMakeUsecase _getLeadsUsecase;

  GetMakeNotifier(
      {required GetMakeUsecase getLeadsUsecase, GetMakeState? initialState})
      : _getLeadsUsecase = getLeadsUsecase,
        super(initialState ?? const GetMakeState.initial());

  getMake() async {
    state = const GetMakeState.loading();
    try {
      final data = await _getLeadsUsecase.call();
      data.fold((l) {
        state = const GetMakeState.loading();
      }, (r) {
        print(r.length);
        print(r.first.name);
        state = GetMakeState.data(r);
      });
    } catch (e) {
      state = GetMakeState.error('$e');
    }
  }
}
