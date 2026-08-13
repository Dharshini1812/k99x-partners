// lib/features/upload/presentation/logic/upload/upload_state_x.dart
//
// Convenience getters over the freezed UploadState union, so call sites
// (like MediaCard wiring) can read `state.isLoading` instead of writing
// a `.when(...)` every time.

import 'package:dealer/features/upload/data/model/upload_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload/upload_state.dart';

extension UploadStateX on UploadState {
  bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);

  bool get isError => maybeWhen(error: (_) => true, orElse: () => false);

  bool get isSuccess => maybeWhen(data: (_) => true, orElse: () => false);

  String? get errorMessage =>
      maybeWhen(error: (msg) => msg, orElse: () => null);

  UploadModel? get uploadedModel =>
      maybeWhen(data: (d) => d, orElse: () => null);
}
