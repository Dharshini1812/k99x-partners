// lib/features/upload/presentation/logic/upload/upload_provider.dart
//
// Datasource/repository/usecase wiring is unchanged from what you had.
// The only change: uploadProvider is now a .family<..., String>, keyed
// by a slot name ('front', 'odometer', 'exteriorVideo', etc). Riverpod
// caches a separate UploadNotifier per key, so uploading the 2nd photo
// can't overwrite the 1st photo's loading/success/error state.

import 'package:dealer/features/upload/data/datasource/remote_datasource.dart';
import 'package:dealer/features/upload/data/repository/repositoryimpl.dart';
import 'package:dealer/features/upload/domain/repository/repository.dart';
import 'package:dealer/features/upload/domain/usecase/add_vehicle_data.dart';
import 'package:dealer/features/upload/domain/usecase/complete_review.dart';
import 'package:dealer/features/upload/domain/usecase/get_vehicle_review.dart';
import 'package:dealer/features/upload/domain/usecase/upload_media.dart';
import 'package:dealer/features/upload/domain/usecase/vehicle_edit.dart';
import 'package:dealer/features/upload/presentation/logic/add_vehicle_data/add_vehicle_notifier.dart';
import 'package:dealer/features/upload/presentation/logic/add_vehicle_data/add_vehicle_state.dart';
import 'package:dealer/features/upload/presentation/logic/complete_review/complete_review_notifier.dart';
import 'package:dealer/features/upload/presentation/logic/complete_review/complete_review_state.dart';
import 'package:dealer/features/upload/presentation/logic/get_review/get_review_notifier.dart';
import 'package:dealer/features/upload/presentation/logic/get_review/get_review_state.dart';
import 'package:dealer/features/upload/presentation/logic/upload/upload_notifier.dart';
import 'package:dealer/features/upload/presentation/logic/upload/upload_state.dart';
import 'package:dealer/features/upload/presentation/logic/upload_edit/vehicle_edit_notifier.dart';
import 'package:dealer/features/upload/presentation/logic/upload_edit/vehicle_edit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Datasource
final uploadDatasourceProvider =
    Provider<UploadDatasource>((ref) => UploadDatasourceImpl(ref: ref));

// Repository
final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => UploadRepositoryImpl(ref.read(uploadDatasourceProvider)),
);

// UseCase
final uploadUseCaseProvider = Provider<UploadMediaUseCase>(
  (ref) => UploadMediaUseCase(ref.read(uploadRepositoryProvider)),
);

// StateNotifier — one independent instance per media slot key,
// e.g. uploadProvider('front'), uploadProvider('odometer').
final uploadProvider =
    StateNotifierProvider.family<UploadNotifier, UploadState, String>(
  (ref, slotKey) => UploadNotifier(ref.read(uploadUseCaseProvider)),
);

final _addVehicleUsecase = Provider<AddvehicleDataUsecase>((ref) =>
    AddvehicleDataUsecase(repository: ref.read(uploadRepositoryProvider)));

final addVehicleData =
    StateNotifierProvider<AddVehicleNotifier, AddVehicleState>((ref) =>
        AddVehicleNotifier(
            addvehicleDataUsecase: ref.read(_addVehicleUsecase)));

//review

final _reviewUsecase = Provider<GetVehicleReview>(
    (ref) => GetVehicleReview(ref.read(uploadRepositoryProvider)));

final vehicleReviewNotifier =
    StateNotifierProvider<VehicleReviewNotifier, VehicleReviewState>(
  (ref) => VehicleReviewNotifier(
    usecase: ref.read(_reviewUsecase),
  ),
);

//complete

final _completeUsecase = Provider<CompleteVehicleListing>(
    (ref) => CompleteVehicleListing(ref.read(uploadRepositoryProvider)));

final completeVehicleNotifier =
    StateNotifierProvider<CompleteVehicleNotifier, CompleteVehicleState>(
  (ref) => CompleteVehicleNotifier(
    usecase: ref.read(_completeUsecase),
  ),
);

//edit

final _editusecase = Provider<GetVehicleForEdit>(
    (ref) => GetVehicleForEdit(ref.read(uploadRepositoryProvider)));

final editVehicleFetchNotifier =
    StateNotifierProvider<EditVehicleFetchNotifier, EditVehicleFetchState>(
  (ref) => EditVehicleFetchNotifier(
    usecase: ref.read(_editusecase),
    ref: ref,
  ),
);

class MediaSlot {
  MediaSlot._();
  static const front = 'front';
  static const odometer = 'odometer';
  static const exteriorVideo = 'exteriorVideo';
  static const interiorVideo = 'interiorVideo';
  static const engineBayVideo = 'engineBayVideo';
  static const tyresVideo = 'tyresVideo';
}
