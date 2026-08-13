import 'dart:developer';

import 'package:dealer/core/common/domain/usecase/get_variant.dart';
import 'package:dealer/core/common/presentation/logic/get_variant/getvariant_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetVariantNotifier extends StateNotifier<GetVariantState> {
  final GetVariantUsecase _getLeadsUsecase;

  GetVariantNotifier(
      {required GetVariantUsecase getLeadsUsecase,
      GetVariantState? initialState})
      : _getLeadsUsecase = getLeadsUsecase,
        super(initialState ?? const GetVariantState.initial());

  getVariants({required int modelId}) async {
    state = const GetVariantState.loading();
    try {
      final data = await _getLeadsUsecase.call(modelId: modelId);
      data.fold((l) {
        log('Variant fetch failed for modelId=$modelId: $l');
        state = const GetVariantState.loading();
      }, (r) {
        log('Variant fetch succeeded: ${r.length} variants');
        state = GetVariantState.data(r);
      });
    } catch (e) {
      state = GetVariantState.error('$e');
    }
  }
}
