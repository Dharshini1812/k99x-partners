// lib/features/upload/presentation/pages/steps/media_capture_step.dart

import 'package:dealer/features/upload/presentation/logic/upload/upload_state_x.dart';
import 'package:dealer/features/upload/presentation/logic/upload_provider.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/landscape_camera_page.dart';
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
    final vehicleId = listing.vehicleId ?? '';

    Future<void> handlePicked(
      String slotKey,
      XFile file,
      void Function(String? path) storeLocalPath,
      void Function(String? url) storeUrl,
    ) async {
      storeLocalPath(file.path);

      if (vehicleId.isEmpty) return;

      await ref.read(uploadProvider(slotKey).notifier).uploadMedia(
            vehicleId: vehicleId,
            mediaType: slotKey,
            filePath: file.path,
          );

      final result = ref.read(uploadProvider(slotKey));
      if (result.isSuccess) {
        final remoteUrl = result.uploadedModel?.data?.url;
        if (remoteUrl != null && remoteUrl.trim().isNotEmpty) {
          storeUrl(remoteUrl);
        }
      }
    }

    Future<void> captureImage(
      String slotKey,
      void Function(String? path) onPicked,
      void Function(String? url) onUploaded,
    ) async {
      final path = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => const LandscapeCameraPage(
            isVideo: false,
            title: 'Capture Vehicle Photo',
          ),
        ),
      );

      if (path != null && path.isNotEmpty) {
        await handlePicked(slotKey, XFile(path), onPicked, onUploaded);
      }
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
      final path = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => const LandscapeCameraPage(
            isVideo: true,
            title: 'Record Vehicle Walkaround',
          ),
        ),
      );

      if (path != null && path.isNotEmpty) {
        await handlePicked(slotKey, XFile(path), onPicked, onUploaded);
      }
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
                vehicleId: vehicleId,
                slotKey: MediaSlot.front,
                title: 'Front Vehicle Image',
                subtitle: "Capture a clear image of the car's front.",
                isVideo: false,
                path: listing.frontImagePath,
                onCapture: () => captureImage(
                  MediaSlot.front,
                  (p) => notifier.update((s) => s.copyWith(frontImagePath: p)),
                  (u) => notifier.update((s) => s.copyWith(frontImagePath: u)),
                ),
                onUpload: () => uploadImage(
                  MediaSlot.front,
                  (p) => notifier.update((s) => s.copyWith(frontImagePath: p)),
                  (u) => notifier.update((s) => s.copyWith(frontImagePath: u)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSlot(
                ref: ref,
                vehicleId: vehicleId,
                slotKey: MediaSlot.odometer,
                title: 'Vehicle Odometer Image',
                subtitle: "Capture a clear image of the car's odometer.",
                isVideo: false,
                path: listing.odometerImagePath,
                onCapture: () => captureImage(
                  MediaSlot.odometer,
                  (p) =>
                      notifier.update((s) => s.copyWith(odometerImagePath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(odometerImagePath: u)),
                ),
                onUpload: () => uploadImage(
                  MediaSlot.odometer,
                  (p) =>
                      notifier.update((s) => s.copyWith(odometerImagePath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(odometerImagePath: u)),
                ),
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
                vehicleId: vehicleId,
                slotKey: MediaSlot.exteriorVideo,
                title: 'Vehicle Exterior',
                subtitle: 'Walk around the entire car, showing all sides.',
                isVideo: true,
                path: listing.exteriorVideoPath,
                onCapture: () => captureVideo(
                  MediaSlot.exteriorVideo,
                  (p) =>
                      notifier.update((s) => s.copyWith(exteriorVideoPath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(exteriorVideoPath: u)),
                ),
                onUpload: () => uploadVideo(
                  MediaSlot.exteriorVideo,
                  (p) =>
                      notifier.update((s) => s.copyWith(exteriorVideoPath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(exteriorVideoPath: u)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSlot(
                ref: ref,
                vehicleId: vehicleId,
                slotKey: MediaSlot.interiorVideo,
                title: 'Vehicle Interior',
                subtitle: 'Pan across the dashboard, seats, and cabin.',
                isVideo: true,
                path: listing.interiorVideoPath,
                onCapture: () => captureVideo(
                  MediaSlot.interiorVideo,
                  (p) =>
                      notifier.update((s) => s.copyWith(interiorVideoPath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(interiorVideoPath: u)),
                ),
                onUpload: () => uploadVideo(
                  MediaSlot.interiorVideo,
                  (p) =>
                      notifier.update((s) => s.copyWith(interiorVideoPath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(interiorVideoPath: u)),
                ),
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
                vehicleId: vehicleId,
                slotKey: MediaSlot.engineBayVideo,
                title: 'Vehicle Engine Bay',
                subtitle: 'Show engine running if possible.',
                isVideo: true,
                path: listing.engineBayVideoPath,
                onCapture: () => captureVideo(
                  MediaSlot.engineBayVideo,
                  (p) =>
                      notifier.update((s) => s.copyWith(engineBayVideoPath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(engineBayVideoPath: u)),
                ),
                onUpload: () => uploadVideo(
                  MediaSlot.engineBayVideo,
                  (p) =>
                      notifier.update((s) => s.copyWith(engineBayVideoPath: p)),
                  (u) =>
                      notifier.update((s) => s.copyWith(engineBayVideoPath: u)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSlot(
                ref: ref,
                vehicleId: vehicleId,
                slotKey: MediaSlot.tyresVideo,
                title: 'Vehicle Tyres',
                subtitle: 'Close-up of each tyre.',
                isVideo: true,
                path: listing.tyresVideoPath,
                onCapture: () => captureVideo(
                  MediaSlot.tyresVideo,
                  (p) => notifier.update((s) => s.copyWith(tyresVideoPath: p)),
                  (u) => notifier.update((s) => s.copyWith(tyresVideoPath: u)),
                ),
                onUpload: () => uploadVideo(
                  MediaSlot.tyresVideo,
                  (p) => notifier.update((s) => s.copyWith(tyresVideoPath: p)),
                  (u) => notifier.update((s) => s.copyWith(tyresVideoPath: u)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlot({
    required WidgetRef ref,
    required String vehicleId,
    required String slotKey,
    required String title,
    required String subtitle,
    required bool isVideo,
    required String? path,
    required VoidCallback onCapture,
    required VoidCallback onUpload,
  }) {
    final uploadState = ref.watch(uploadProvider(slotKey));

    Future<void> retry() async {
      if (path == null || vehicleId.isEmpty) return;
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
      isUploading: uploadState.isLoading,
      isUploadError: uploadState.isError,
      uploadErrorMessage: uploadState.errorMessage,
      onRetryUpload: retry,
    );
  }
}
