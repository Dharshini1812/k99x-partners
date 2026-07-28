import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'getvariant_state.freezed.dart';

@freezed
class GetVariantState with _$GetVariantState {
  const factory GetVariantState.initial() = _GetVariantStateInitial;
  const factory GetVariantState.loading() = _GetVariantStateLoading;
  const factory GetVariantState.data(List<VariantModel> data) =
      _GetVariantStateData;
  const factory GetVariantState.error(String msg) = _GetVariantStateError;
}
