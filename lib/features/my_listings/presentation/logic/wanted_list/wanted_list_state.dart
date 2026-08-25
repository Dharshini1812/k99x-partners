import 'package:dealer/features/my_listings/data/model/wanted_list_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'wanted_list_state.freezed.dart';

@freezed
class WantedListState with _$WantedListState {
  const factory WantedListState.initial() = _WantedListStateInitial;
  const factory WantedListState.loading() = _WantedListStateLoading;
  const factory WantedListState.data(WantedListResponseModel data) =
      _WantedListStateData;
  const factory WantedListState.error(String msg) = _WantedListStateError;
}
