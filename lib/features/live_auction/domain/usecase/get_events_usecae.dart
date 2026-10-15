import 'package:dealer/features/live_auction/data/model/event_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetEventsUseCase {
  final AuctionRepository repository;

  GetEventsUseCase({required this.repository});

  Future<EventResponseModel> call() async {
    return await repository.getEvents();
  }
}
