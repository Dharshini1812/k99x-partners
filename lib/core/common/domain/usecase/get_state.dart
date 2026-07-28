import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class GetStatesUsecase {
  final CommonRepository _commonRepository;

  GetStatesUsecase({required CommonRepository commonRepository})
      : _commonRepository = commonRepository;

  Future<Either<Failure, List<StateModel>>> getStates() async {
    return _commonRepository.getState();
  }
}
