// lib/features/live_auction/presentation/logic/event_vehicles_state.dart

import 'package:dealer/features/live_auction/data/model/new_auction_detail_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_vehicles_state.freezed.dart';

@freezed
class EventVehiclesState with _$EventVehiclesState {
  const factory EventVehiclesState.initial() = _EventVehiclesInitial;
  const factory EventVehiclesState.loading() = _EventVehiclesLoading;
  const factory EventVehiclesState.data(EventVehiclesResponse data) =
      _EventVehiclesData;
  const factory EventVehiclesState.error(String msg) = _EventVehiclesError;
}
