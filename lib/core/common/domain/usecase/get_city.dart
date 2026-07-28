import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class GetCityUsecase {
  final CommonRepository _commonRepository;

  GetCityUsecase({required CommonRepository commonRepository})
      : _commonRepository = commonRepository;

  Future<Either<Failure, List<CityModel>>> getCity({String? id}) async {
    return _commonRepository.getCity(id: id);
  }
}
