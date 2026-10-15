import 'package:dealer/features/live_auction/domain/usecase/get_events_usecae.dart';
import 'package:dealer/features/live_auction/presentation/logic/get_events/get_events_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveEventsNotifier extends StateNotifier<LiveEventState> {
  final GetEventsUseCase getEventsUseCase;

  LiveEventsNotifier({
    required this.getEventsUseCase,
  }) : super(const LiveEventState.initial());

  Future<void> fetchEvents() async {
    state = const LiveEventState.loading();
    try {
      final response = await getEventsUseCase();
      state = LiveEventState.data(response);
    } catch (e) {
      state = LiveEventState.error(e.toString());
    }
  }
}
