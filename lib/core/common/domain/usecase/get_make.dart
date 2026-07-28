import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class GetMakeUsecase {
  final CommonRepository _repository;

  GetMakeUsecase({required CommonRepository leadRepository})
      : _repository = leadRepository;

  Future<Either<Failure, List<MakeModel>>> call() async {
    return await _repository.getMake();
  }
}
