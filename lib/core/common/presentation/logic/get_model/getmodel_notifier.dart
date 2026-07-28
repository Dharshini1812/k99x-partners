import 'package:dealer/core/common/domain/usecase/get_model.dart';
import 'package:dealer/core/common/presentation/logic/get_model/getmodel_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetModelNotifier extends StateNotifier<GetModelState> {
  final GetModelUsecase _getLeadsUsecase;

  GetModelNotifier(
      {required GetModelUsecase getLeadsUsecase, GetModelState? initialState})
      : _getLeadsUsecase = getLeadsUsecase,
        super(initialState ?? const GetModelState.initial());

  getModel({required int makeId}) async {
    state = const GetModelState.loading();
    try {
      final data = await _getLeadsUsecase.call(makeId: makeId);
      data.fold((l) {
        state = const GetModelState.loading();
      }, (r) {
        state = GetModelState.data(r);
      });
    } catch (e) {
      state = GetModelState.error('$e');
    }
  }
}
