import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class GetRcUsecase {
  final CommonRepository _commonRepository;
  GetRcUsecase(this._commonRepository);
  Future<Either<Failure, RCDetailsModel>> getRcUsecase(String vehRegId) async {
    final result = await _commonRepository.getRcDetails(vehRegId);
    return result;
  }
}
