// lib/features/upload/presentation/widgets/review_step.dart

import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload_provider.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/review_grid.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewStep extends ConsumerStatefulWidget {
  final TextEditingController dealerPriceController;

  const ReviewStep({super.key, required this.dealerPriceController});

  @override
  ConsumerState<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<ReviewStep> {
  bool _isCompleting = false;

  void _resetFormAndGoHome(BuildContext context) {
    // 1. Clear Local Controllers
    widget.dealerPriceController.clear();

    // 2. Reset All Upload Form Riverpod States
    ref.read(listingStepProvider.notifier).state = 0;
    ref.read(listingProvider.notifier).reset();
    ref.read(editVehicleProvider.notifier).state = (model: null, refreshKey: 0);

    // 3. Reset All Media Upload Slot Providers
    const mediaSlots = [
      MediaSlot.front,
      MediaSlot.odometer,
      MediaSlot.exteriorVideo,
      MediaSlot.interiorVideo,
      MediaSlot.engineBayVideo,
      MediaSlot.tyresVideo,
    ];
    for (final slot in mediaSlots) {
      ref.read(uploadProvider(slot).notifier).reset();
    }

    // 4. Set Bottom Nav Index to Home (Index 0) and Pop back
    ref.read(bottomNavIndexProvider.notifier).state = 0;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // lib/features/upload/presentation/widgets/review_step.dart

  Future<void> _showSuccessDialog(
    BuildContext context, {
    required bool isEdit,
    required String message,
  }) {
    final title = isEdit
        ? 'Vehicle Updated Successfully!'
        : 'Vehicle Listed Successfully!';

    final defaultBody = isEdit
        ? 'Your vehicle details have been updated successfully.'
        : 'Your vehicle has been submitted for auction review.';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF2E9E5B),
          size: 48,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(0xFF11142A),
          ),
        ),
        content: Text(
          message.isNotEmpty ? message : defaultBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF4B5563),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 140,
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _resetFormAndGoHome(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9E5B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Go to Home',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_isCompleting) return;

    final listing = ref.read(listingProvider);
    final vehicleId = listing.vehicleId;

    if (vehicleId == null || vehicleId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Missing vehicle ID — please restart the listing flow.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine if this session was an edit
    final isEdit = ref.read(editVehicleProvider).model != null ||
        (listing.savedMakeName != null && listing.savedMakeName!.isNotEmpty);

    final text = widget.dealerPriceController.text.trim();
    final double? dealerPrice = text.isNotEmpty ? double.tryParse(text) : 0.0;

    setState(() => _isCompleting = true);

    try {
      final response =
          await ref.read(completeVehicleNotifier.notifier).complete(
                CompleteVehicleRequestModel(
                  vehicleId: vehicleId,
                  dealerPrice: dealerPrice ?? 0.0,
                ),
              );

      if (!mounted) return;
      setState(() => _isCompleting = false);

      if (response == null || !response.success) {
        final errorMsg = ref.read(completeVehicleNotifier).maybeWhen(
              error: (msg) => msg,
              orElse: () => 'Could not submit the listing. Please try again.',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
        return;
      }

      // Display the dialog with edit/add contextual messaging
      await _showSuccessDialog(
        context,
        isEdit: isEdit,
        message: response.message,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit listing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);
    final reviewState = ref.watch(vehicleReviewNotifier);

    return StepScaffold(
      nextLabel: 'Submit Listing',
      nextEnabled: listing.agreedToTerms && !_isCompleting,
      onNext: () => _submit(context),
      children: [
        const Text('List Your Vehicle for Sale', style: UploadText.stepTitle),
        const Text(
          'Review all details before submitting your listing.',
          style: UploadText.stepSubtitle,
        ),
        const SizedBox(height: 14),
        reviewState.maybeWhen(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (msg) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Could not load full review details: $msg',
              style: const TextStyle(color: Colors.red, fontSize: 12.5),
            ),
          ),
          data: (review) => SectionCard(
            title: 'Vehicle Details',
            children: [
              ReviewGrid(pairs: [
                ('Registration Number', review.data.vehicle.regNo ?? '-'),
                ('Year', '${review.data.vehicle.mfgYear ?? '-'}'),
                ('Make', review.data.vehicle.makeName ?? '-'),
                ('Model', review.data.vehicle.modelName ?? '-'),
                ('Variant/Trim', review.data.vehicle.variantName ?? '-'),
                ('Mileage', '${review.data.vehicle.kmDriven ?? '-'} KM'),
                ('Body Style', review.data.vehicle.bodyStyle ?? '-'),
                ('Fuel Type', review.data.vehicle.fuelType ?? '-'),
                ('Transmission', review.data.vehicle.transmission ?? '-'),
                ('City', review.data.vehicle.cityName ?? '-'),
                ('State', review.data.vehicle.stateName ?? '-'),
                (
                  'Engine Condition',
                  review.data.inspection.engineCondition ?? '-'
                ),
                (
                  'Exterior Condition',
                  review.data.inspection.exteriorCondition ?? '-'
                ),
                (
                  'Interior Condition',
                  review.data.inspection.interiorCondition ?? '-'
                ),
                (
                  'Number of Owners',
                  '${review.data.inspection.ownerCount ?? '-'}'
                ),
                (
                  'Accident History',
                  review.data.inspection.accidentHistory ?? '-'
                ),
              ]),
            ],
          ),
          orElse: () => SectionCard(
            title: 'Vehicle Details',
            children: [
              ReviewGrid(pairs: [
                ('Registration Number', listing.registrationNumber ?? '-'),
                ('Year', listing.year ?? '-'),
                ('Mileage', '${listing.mileageKm ?? '-'} KM'),
                ('Body Style', listing.bodyStyle ?? '-'),
                ('Fuel Type', listing.fuelType ?? '-'),
                ('Transmission', listing.transmission ?? '-'),
                ('City', listing.city ?? '-'),
                ('State', listing.state ?? '-'),
                ('Engine Condition', listing.engineCondition ?? '-'),
                ('Exterior Condition', listing.exteriorCondition ?? '-'),
                ('Interior Condition', listing.interiorCondition ?? '-'),
                ('Number of Owners', listing.numberOfOwners ?? '-'),
                ('Accident History', listing.accidentHistory ?? '-'),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Full-Width Tappable Terms Agreement Row ──────────────────────────
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              notifier
                  .update((s) => s.copyWith(agreedToTerms: !s.agreedToTerms));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: listing.agreedToTerms,
                      activeColor: UploadColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) {
                        notifier.update(
                            (s) => s.copyWith(agreedToTerms: v ?? false));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'I agree to the Auction Listing Terms and Conditions and Privacy Policy',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF344054),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_isCompleting) ...[
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }
}
