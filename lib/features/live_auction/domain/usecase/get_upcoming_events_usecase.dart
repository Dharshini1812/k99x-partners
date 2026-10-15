import 'package:dealer/features/live_auction/data/model/event_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class GetUpcomingEventUseCase {
  final AuctionRepository repository;

  GetUpcomingEventUseCase({required this.repository});

  Future<EventResponseModel> call() async {
    return await repository.getUpcomingEvents();
  }
}
