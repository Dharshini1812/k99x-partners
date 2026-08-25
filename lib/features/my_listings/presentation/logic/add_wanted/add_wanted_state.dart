// lib/features/wanted/presentation/logic/wanted_save/wanted_save_state.dart
import 'package:dealer/features/my_listings/data/model/add_wanted_list_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'add_wanted_state.freezed.dart';

@freezed
class WantedSaveState with _$WantedSaveState {
  const factory WantedSaveState.initial() = _WantedSaveStateInitial;
  const factory WantedSaveState.loading() = _WantedSaveStateLoading;
  const factory WantedSaveState.data(WantedListingSaveResponseModel data) =
      _WantedSaveStateData;
  const factory WantedSaveState.error(String msg) = _WantedSaveStateError;
}
