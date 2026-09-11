import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/lender_model.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class GetLenderUsecase {
  final CommonRepository _repository;

  GetLenderUsecase({required CommonRepository leadRepository})
      : _repository = leadRepository;

  Future<Either<Failure, List<LenderModel>>> call() async {
    return await _repository.getLenderList();
  }
}
