import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class GetModelUsecase {
  final CommonRepository _commonRepository;

  GetModelUsecase({required CommonRepository leadRepository})
      : _commonRepository = leadRepository;

  Future<Either<Failure, List<ModelModel>>> call({required int makeId}) async {
    return await _commonRepository.getModel(makeId: makeId);
  }
}
