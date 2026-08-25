// lib/features/wanted/presentation/logic/wanted_save/wanted_save_notifier.dart

import 'package:dealer/features/my_listings/data/model/add_wanted_list_model.dart';
import 'package:dealer/features/my_listings/domain/usecase/add_wanted.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_wanted/add_wanted_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WantedSaveNotifier extends StateNotifier<WantedSaveState> {
  final SaveWantedListing _usecase;

  WantedSaveNotifier({required SaveWantedListing usecase})
      : _usecase = usecase,
        super(const WantedSaveState.initial());

  Future<bool> save(WantedListingRequestModel request) async {
    state = const WantedSaveState.loading();
    try {
      final result = await _usecase(request);
      return result.fold((l) {
        state = WantedSaveState.error(l.msg ?? 'Something went wrong');
        return false;
      }, (r) {
        state = WantedSaveState.data(r);
        return true;
      });
    } catch (e) {
      state = WantedSaveState.error(e.toString());
      return false;
    }
  }

  void reset() => state = const WantedSaveState.initial();
}
