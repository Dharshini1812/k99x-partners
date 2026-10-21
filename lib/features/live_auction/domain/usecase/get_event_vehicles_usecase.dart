// lib/features/live_auction/domain/usecase/get_event_vehicles_usecase.dart

import 'package:dealer/features/live_auction/data/model/new_auction_detail_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetEventVehiclesUseCase {
  final AuctionRepository _repository;

  GetEventVehiclesUseCase(this._repository);

  Future<EventVehiclesResponse> call(String eventId) async {
    return await _repository.getEventVehicles(eventId: eventId);
  }
}
