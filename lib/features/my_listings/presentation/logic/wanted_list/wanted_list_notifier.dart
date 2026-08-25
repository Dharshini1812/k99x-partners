import 'package:dealer/features/my_listings/domain/usecase/wanted_list.dart';
import 'package:dealer/features/my_listings/presentation/logic/wanted_list/wanted_list_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WantedListNotifier extends StateNotifier<WantedListState> {
  final WantedList _wantedUsecase;

  WantedListNotifier(
      {required WantedList wantedUsecase, WantedListState? initState})
      : _wantedUsecase = wantedUsecase,
        super(initState ?? const WantedListState.initial());

  Future<void> getWantedList() async {
    state = const WantedListState.initial();
    try {
      final result = await _wantedUsecase.getWantedList();
      result.fold((l) {
        state = WantedListState.error(l.msg ?? '');
      }, (r) {
        state = WantedListState.data(r);
      });
    } catch (e) {
      state = WantedListState.error(e.toString());
    }
  }
}
