import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/my_listings/data/model/wanted_list_model.dart';
import 'package:dealer/features/my_listings/domain/repository/repository.dart';

class WantedList {
  final MyListingsRepository _listingsRepository;

  WantedList({required MyListingsRepository listingsRepository})
      : _listingsRepository = listingsRepository;

  Future<Either<Failure, WantedListResponseModel>> getWantedList() async {
    return await _listingsRepository.getWantedList();
  }
}
