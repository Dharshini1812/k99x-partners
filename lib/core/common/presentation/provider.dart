import 'package:dealer/core/common/data/datasource/remote_datasource.dart';
import 'package:dealer/core/common/data/repository/repositoryimpl.dart';
import 'package:dealer/core/common/domain/repository/repository.dart';
import 'package:dealer/core/common/domain/usecase/get_city.dart';
import 'package:dealer/core/common/domain/usecase/get_make.dart';
import 'package:dealer/core/common/domain/usecase/get_model.dart';
import 'package:dealer/core/common/domain/usecase/get_rc_details.dart';
import 'package:dealer/core/common/domain/usecase/get_state.dart';
import 'package:dealer/core/common/domain/usecase/get_variant.dart';
import 'package:dealer/core/common/presentation/logic/get_city/get_city_notifier.dart';
import 'package:dealer/core/common/presentation/logic/get_city/get_city_state.dart';
import 'package:dealer/core/common/presentation/logic/get_make/getmake_notifier.dart';
import 'package:dealer/core/common/presentation/logic/get_make/getmake_state.dart';
import 'package:dealer/core/common/presentation/logic/get_model/getmodel_notifier.dart';
import 'package:dealer/core/common/presentation/logic/get_model/getmodel_state.dart';
import 'package:dealer/core/common/presentation/logic/get_rc_details/get_rc_notifier.dart';
import 'package:dealer/core/common/presentation/logic/get_rc_details/get_rc_state.dart';
import 'package:dealer/core/common/presentation/logic/get_state/get_state_notifier.dart';
import 'package:dealer/core/common/presentation/logic/get_state/get_state_state.dart';
import 'package:dealer/core/common/presentation/logic/get_variant/getvariant_notifier.dart';
import 'package:dealer/core/common/presentation/logic/get_variant/getvariant_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _commonDatasource =
    Provider<CommonDatasource>((ref) => CommonDatasourceimpl(ref));

final _commonRepository = Provider<CommonRepository>((ref) =>
    CommonRepositoryImpl(commonDatasource: ref.read(_commonDatasource)));

//state

final _stateUsecase = Provider<GetStatesUsecase>(
    (ref) => GetStatesUsecase(commonRepository: ref.read(_commonRepository)));

final getStateProvider = StateNotifierProvider<GetStateNotifier, GetStateState>(
    (ref) => GetStateNotifier(getStateState: ref.read(_stateUsecase)));

//city

final _cityUsecase = Provider<GetCityUsecase>(
    (ref) => GetCityUsecase(commonRepository: ref.read(_commonRepository)));

final getCityProvider = StateNotifierProvider<GetCityNotifier, GetCityState>(
    (ref) => GetCityNotifier(getStateState: ref.read(_cityUsecase)));

final _getMakeUsecase = Provider<GetMakeUsecase>(
    (ref) => GetMakeUsecase(leadRepository: ref.read(_commonRepository)));
final _getModelUsecase = Provider<GetModelUsecase>(
    (ref) => GetModelUsecase(leadRepository: ref.read(_commonRepository)));
final _getVariantUsecase = Provider<GetVariantUsecase>(
    (ref) => GetVariantUsecase(leadRepository: ref.read(_commonRepository)));

final getMakeProvider = StateNotifierProvider<GetMakeNotifier, GetMakeState>(
    (ref) => GetMakeNotifier(getLeadsUsecase: ref.read(_getMakeUsecase)));
final getModelProvider = StateNotifierProvider<GetModelNotifier, GetModelState>(
    (ref) => GetModelNotifier(getLeadsUsecase: ref.read(_getModelUsecase)));
final getVariantProvider =
    StateNotifierProvider<GetVariantNotifier, GetVariantState>((ref) =>
        GetVariantNotifier(getLeadsUsecase: ref.read(_getVariantUsecase)));

final _rcUsecase =
    Provider<GetRcUsecase>((ref) => GetRcUsecase(ref.read(_commonRepository)));
final getRcProvider = StateNotifierProvider<GetRcDetailsNotifier, GetRcState>(
    (ref) => GetRcDetailsNotifier(usecase: ref.read(_rcUsecase)));
