// lib/features/live_auction/presentation/logic/event_vehicles_notifier.dart

import 'package:dealer/features/live_auction/domain/usecase/get_event_vehicles_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_event_vehicles/event_vehicles_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventVehiclesNotifier extends StateNotifier<EventVehiclesState> {
  final GetEventVehiclesUseCase _getEventVehiclesUseCase;

  EventVehiclesNotifier(this._getEventVehiclesUseCase)
      : super(const EventVehiclesState.initial());

  Future<void> fetchEventVehicles(String eventId) async {
    state = const EventVehiclesState.loading();
    try {
      final response = await _getEventVehiclesUseCase(eventId);
      state = EventVehiclesState.data(response);
    } catch (e) {
      state = EventVehiclesState.error(e.toString());
    }
  }
}
