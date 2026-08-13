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
import 'package:dealer/features/upload/domain/usecase/upload_media.dart';
import 'package:dealer/features/upload/presentation/logic/upload/upload_notifier.dart';
import 'package:dealer/features/upload/presentation/logic/upload/upload_state.dart';
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

/// The set of slot keys used across the media step — keep this in sync
/// with the mediaType strings your backend expects.
class MediaSlot {
  MediaSlot._();
  static const front = 'front';
  static const odometer = 'odometer';
  static const exteriorVideo = 'exteriorVideo';
  static const interiorVideo = 'interiorVideo';
  static const engineBayVideo = 'engineBayVideo';
  static const tyresVideo = 'tyresVideo';
}
