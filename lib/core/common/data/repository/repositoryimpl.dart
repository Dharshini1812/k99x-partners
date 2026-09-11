import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/datasource/remote_datasource.dart';
import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/lender_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/error/failure.dart';

class CommonRepositoryImpl implements CommonRepository {
  final CommonDatasource _commonDatasource;

  CommonRepositoryImpl({required CommonDatasource commonDatasource})
      : _commonDatasource = commonDatasource;

  @override
  Future<Either<Failure, List<StateModel>>> getState() async {
    try {
      final data = await _commonDatasource.getState();
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CityModel>>> getCity({String? id}) async {
    try {
      final data = await _commonDatasource.getCity(id: id);
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MakeModel>>> getMake() async {
    try {
      final data = await _commonDatasource.getMake();
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: '$e'));
    }
  }

  @override
  Future<Either<Failure, List<ModelModel>>> getModel({
    required int makeId,
  }) async {
    try {
      final data = await _commonDatasource.getModel(makeId: makeId);
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: '$e'));
    }
  }

  @override
  Future<Either<Failure, List<VariantModel>>> getVariant(
      {required int modelId}) async {
    try {
      final data = await _commonDatasource.getVariant(modelId: modelId);
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: '$e'));
    }
  }

  @override
  Future<Either<Failure, RCDetailsModel>> getRcDetails(String vehRegId) async {
    try {
      final data = await _commonDatasource.getRcDetails(vehRegId);
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LenderModel>>> getLenderList() async {
    try {
      final data = await _commonDatasource.getLenderList();
      return Right(data);
    } catch (e) {
      return Left(CustomFailure(msg: e.toString()));
    }
  }
}
