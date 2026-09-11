// lib/features/live_auction/domain/usecase/bid_activity_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/core/usecase/usecase.dart';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:dealer/features/live_auction/domain/repository/repository.dart';

class BidActivityUseCase implements UseCase<BidActivityData, String> {
  final AuctionRepository repository;

  BidActivityUseCase(this.repository);

  @override
  Future<Either<Failure, BidActivityData>> call(String vehicleId) async {
    return await repository.getBidActivity(vehicleId);
  }
}
