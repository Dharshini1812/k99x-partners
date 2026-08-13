import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/domain/usecase/get_rc_details.dart';
import 'package:dealer/core/common/presentation/logic/get_rc_details/get_rc_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetRcDetailsNotifier extends StateNotifier<GetRcState> {
  final GetRcUsecase _getRcUsecase;
  GetRcDetailsNotifier({
    required GetRcUsecase usecase,
    GetRcState? initialState,
  })  : _getRcUsecase = usecase,
        super(initialState ?? const GetRcState.initial());

  Future<RCDetailsModel> getRcDetails(String vehRegId) async {
    state = const GetRcState.loading();
    final result = await _getRcUsecase.getRcUsecase(vehRegId);
    return result.fold(
      (l) {
        state = GetRcState.error(l.msg ?? '');
        throw Exception(l.msg ?? 'Unable to fetch RC details');
      },
      (r) {
        state = GetRcState.data(r);
        return r;
      },
    );
  }
}
