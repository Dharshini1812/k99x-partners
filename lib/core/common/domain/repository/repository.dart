import 'package:dartz/dartz.dart';
import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/error/failure.dart';

abstract class CommonRepository {
  Future<Either<Failure, List<StateModel>>> getState();
  Future<Either<Failure, List<CityModel>>> getCity({String? id});
  Future<Either<Failure, List<MakeModel>>> getMake();
  Future<Either<Failure, List<ModelModel>>> getModel({
    required int makeId,
  });

  Future<Either<Failure, List<VariantModel>>> getVariant({
    required int modelId,
  });
}
