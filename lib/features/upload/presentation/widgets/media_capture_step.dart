// lib/features/upload/presentation/pages/steps/media_capture_step.dart
//
// Step 3 of the listing flow: photos + walkaround videos.
//
// Upload integration: picking a file (capture or gallery) immediately
// kicks off a network upload via uploadProvider(slotKey) — a family
// provider, so each of the 6 slots has its own isolated loading/
// success/error state (see logic/upload/upload_provider.dart).
//
// ASSUMPTION (adjust if wrong): a `vehicleId` already exists by the time
// the user reaches this step — e.g. created when step 1 was submitted —
// and lives at `listing.vehicleId`. If your VehicleListingModel doesn't
// have that field yet, add `final String? vehicleId;` to it. If the
// vehicle isn't created until final submit, this step needs to hold
// files locally and defer all uploads to the review step's submit
// instead — say so and I'll restructure this for that flow.

import 'package:dealer/features/upload/presentation/logic/upload/upload_state_x.dart';
import 'package:dealer/features/upload/presentation/logic/upload_provider.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/media_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class MediaCaptureStep extends ConsumerWidget {
  final VoidCallback onNext;

  const MediaCaptureStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);
    final picker = ImagePicker();
    const vehicleId =
        'KL782101448124617385'; // ADAPT: see note above if this field doesn't exist yet

    // Fires after a file is picked for [slotKey]: stores the local path
    // immediately (so the preview shows), kicks off the upload, then on
    // success stores the returned URL via [storeUrl].
    //
    // ADAPT: `result.data?.url` assumes UploadModel has a `url` field —
    // rename to whatever your UploadModel actually calls the uploaded
    // file's location.
    Future<void> handlePicked(
      String slotKey,
      XFile file,
      void Function(String? path) storeLocalPath,
      void Function(String? url) storeUrl,
    ) async {
      storeLocalPath(file.path);
      if (vehicleId.isEmpty) {
        return; // nothing to upload against yet
      }
      await ref.read(uploadProvider(slotKey).notifier).uploadMedia(
            vehicleId: vehicleId,
            mediaType: slotKey,
            filePath: file.path,
          );
      final result = ref.read(uploadProvider(slotKey));
      if (result.isSuccess) {
        // ADAPT: assumes UploadModel.data.url — if your backend's data
        // object uses a different key, change it in UploadMediaData
        // (data/model/upload_model.dart), not here.
        storeUrl(result.uploadedModel?.data?.url);
      }
    }

    Future<void> captureImage(
      String slotKey,
      void Function(String? path) onPicked,
      void Function(String? url) onUploaded,
    ) async {
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file != null) await handlePicked(slotKey, file, onPicked, onUploaded);
    }

    Future<void> uploadImage(
      String slotKey,
      void Function(String? path) onPicked,
      void Function(String? url) onUploaded,
    ) async {
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) await handlePicked(slotKey, file, onPicked, onUploaded);
    }

    Future<void> captureVideo(
      String slotKey,
      void Function(String? path) onPicked,
      void Function(String? url) onUploaded,
    ) async {
      final file = await picker.pickVideo(source: ImageSource.camera);
      if (file != null) await handlePicked(slotKey, file, onPicked, onUploaded);
    }

    Future<void> uploadVideo(
      String slotKey,
      void Function(String? path) onPicked,
      void Function(String? url) onUploaded,
    ) async {
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) await handlePicked(slotKey, file, onPicked, onUploaded);
    }

    return StepScaffold(
      onNext: onNext,
      nextLabel: 'Next: Submit for Review',
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSlot(
                ref: ref,
                slotKey: MediaSlot.front,
                title: 'Front Vehicle Image',
                subtitle: "Capture a clear image of the car's front.",
                isVideo: false,
                path: listing.frontImagePath,
                onCapture: () => captureImage(
                    MediaSlot.front,
                    (p) =>
                        notifier.update((s) => s.copyWith(frontImagePath: p)),
                    (u) =>
                        notifier.update((s) => s.copyWith(frontImagePath: u))),
                onUpload: () => uploadImage(
                    MediaSlot.front,
                    (p) =>
                        notifier.update((s) => s.copyWith(frontImagePath: p)),
                    (u) =>
                        notifier.update((s) => s.copyWith(frontImagePath: u))),
                onRemove: () =>
                    notifier.update((s) => s.copyWith(frontImagePath: null)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSlot(
                ref: ref,
                slotKey: MediaSlot.odometer,
                title: 'Vehicle Odometer Image',
                subtitle: "Capture a clear image of the car's odometer.",
                isVideo: false,
                path: listing.odometerImagePath,
                onCapture: () => captureImage(
                    MediaSlot.odometer,
                    (p) => notifier
                        .update((s) => s.copyWith(odometerImagePath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(odometerImagePath: u))),
                onUpload: () => uploadImage(
                    MediaSlot.odometer,
                    (p) => notifier
                        .update((s) => s.copyWith(odometerImagePath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(odometerImagePath: u))),
                onRemove: () =>
                    notifier.update((s) => s.copyWith(odometerImagePath: null)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSlot(
                ref: ref,
                slotKey: MediaSlot.exteriorVideo,
                title: 'Vehicle Exterior',
                subtitle: 'Walk around the entire car, showing all sides.',
                isVideo: true,
                path: listing.exteriorVideoPath,
                onCapture: () => captureVideo(
                    MediaSlot.exteriorVideo,
                    (p) => notifier
                        .update((s) => s.copyWith(exteriorVideoPath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(exteriorVideoPath: u))),
                onUpload: () => uploadVideo(
                    MediaSlot.exteriorVideo,
                    (p) => notifier
                        .update((s) => s.copyWith(exteriorVideoPath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(exteriorVideoPath: u))),
                onRemove: () =>
                    notifier.update((s) => s.copyWith(exteriorVideoPath: null)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSlot(
                ref: ref,
                slotKey: MediaSlot.interiorVideo,
                title: 'Vehicle Interior',
                subtitle: 'Pan across the dashboard, seats, and cabin.',
                isVideo: true,
                path: listing.interiorVideoPath,
                onCapture: () => captureVideo(
                    MediaSlot.interiorVideo,
                    (p) => notifier
                        .update((s) => s.copyWith(interiorVideoPath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(interiorVideoPath: u))),
                onUpload: () => uploadVideo(
                    MediaSlot.interiorVideo,
                    (p) => notifier
                        .update((s) => s.copyWith(interiorVideoPath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(interiorVideoPath: u))),
                onRemove: () =>
                    notifier.update((s) => s.copyWith(interiorVideoPath: null)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSlot(
                ref: ref,
                slotKey: MediaSlot.engineBayVideo,
                title: 'Vehicle Engine Bay',
                subtitle: 'Show engine running if possible.',
                isVideo: true,
                path: listing.engineBayVideoPath,
                onCapture: () => captureVideo(
                    MediaSlot.engineBayVideo,
                    (p) => notifier
                        .update((s) => s.copyWith(engineBayVideoPath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(engineBayVideoPath: u))),
                onUpload: () => uploadVideo(
                    MediaSlot.engineBayVideo,
                    (p) => notifier
                        .update((s) => s.copyWith(engineBayVideoPath: p)),
                    (u) => notifier
                        .update((s) => s.copyWith(engineBayVideoPath: u))),
                onRemove: () => notifier
                    .update((s) => s.copyWith(engineBayVideoPath: null)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSlot(
                ref: ref,
                slotKey: MediaSlot.tyresVideo,
                title: 'Vehicle Tyres',
                subtitle: 'Close-up of each tyre.',
                isVideo: true,
                path: listing.tyresVideoPath,
                onCapture: () => captureVideo(
                    MediaSlot.tyresVideo,
                    (p) =>
                        notifier.update((s) => s.copyWith(tyresVideoPath: p)),
                    (u) =>
                        notifier.update((s) => s.copyWith(tyresVideoPath: u))),
                onUpload: () => uploadVideo(
                    MediaSlot.tyresVideo,
                    (p) =>
                        notifier.update((s) => s.copyWith(tyresVideoPath: p)),
                    (u) =>
                        notifier.update((s) => s.copyWith(tyresVideoPath: u))),
                onRemove: () =>
                    notifier.update((s) => s.copyWith(tyresVideoPath: null)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Reads this slot's upload state and builds the MediaCard with
  /// progress/error reflected. Retry re-runs the same upload against
  /// the already-picked local file, so no re-picking is needed.
  Widget _buildSlot({
    required WidgetRef ref,
    required String slotKey,
    required String title,
    required String subtitle,
    required bool isVideo,
    required String? path,
    required VoidCallback onCapture,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    final uploadState = ref.watch(uploadProvider(slotKey));

    Future<void> retry() async {
      if (path == null) return;
      const vehicleId = 'KL782101448124617385'; // ADAPT: see file-header note
      if (vehicleId.isEmpty) return;
      await ref.read(uploadProvider(slotKey).notifier).uploadMedia(
            vehicleId: vehicleId,
            mediaType: slotKey,
            filePath: path,
          );
    }

    return MediaCard(
      title: title,
      subtitle: subtitle,
      isVideo: isVideo,
      path: path,
      onCapture: onCapture,
      onUpload: onUpload,
      onRemove: () {
        ref.read(uploadProvider(slotKey).notifier).reset();
        onRemove();
      },
      isUploading: uploadState.isLoading,
      isUploadError: uploadState.isError,
      uploadErrorMessage: uploadState.errorMessage,
      onRetryUpload: retry,
    );
  }
}
