import 'package:dealer/features/live_auction/domain/usecase/get_upcoming_events_usecase.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_upcoming_events/get_up_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpcomingEventsNotifier extends StateNotifier<UpcomingEventState> {
  final GetUpcomingEventUseCase getEventsUseCase;

  UpcomingEventsNotifier({
    required this.getEventsUseCase,
  }) : super(const UpcomingEventState.initial());

  Future<void> fetchUpEvents() async {
    state = const UpcomingEventState.loading();
    try {
      final response = await getEventsUseCase();
      state = UpcomingEventState.data(response);
    } catch (e) {
      state = UpcomingEventState.error(e.toString());
    }
  }
}
