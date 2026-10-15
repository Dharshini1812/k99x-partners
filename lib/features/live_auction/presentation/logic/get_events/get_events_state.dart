import 'package:dealer/features/live_auction/data/model/event_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_events_state.freezed.dart';

@freezed
class LiveEventState with _$LiveEventState {
  const factory LiveEventState.initial() = _LiveEventStateInitial;
  const factory LiveEventState.loading() = _LiveEventStateLoading;
  const factory LiveEventState.data(EventResponseModel events) =
      _LiveEventStateData;
  const factory LiveEventState.error(String msg) = _LiveEventStateError;
}
