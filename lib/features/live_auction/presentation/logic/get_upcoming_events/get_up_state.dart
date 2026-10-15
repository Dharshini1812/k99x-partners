import 'package:dealer/features/live_auction/data/model/event_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_up_state.freezed.dart';

@freezed
class UpcomingEventState with _$UpcomingEventState {
  const factory UpcomingEventState.initial() = _UpcomingEventStateInitial;
  const factory UpcomingEventState.loading() = _UpcomingEventStateLoading;
  const factory UpcomingEventState.data(EventResponseModel events) =
      _UpcomingEventStateData;
  const factory UpcomingEventState.error(String msg) = _UpcomingEventStateError;
}
