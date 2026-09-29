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

  Future<void> _submit(BuildContext context) async {
    if (_isCompleting) return;

    final listing = ref.read(listingProvider);
    final vehicleId = listing.vehicleId;

    if (vehicleId == null || vehicleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing vehicle ID — please restart the listing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dealerPrice =
        double.tryParse(widget.dealerPriceController.text.trim());
    if (dealerPrice == null || dealerPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid dealer expected price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCompleting = true);

    final response = await ref.read(completeVehicleNotifier.notifier).complete(
          CompleteVehicleRequestModel(
            vehicleId: vehicleId,
            dealerPrice: dealerPrice,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.message.isNotEmpty
              ? response.message
              : 'Vehicle listed successfully!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // ── 1. Clear All Local Controllers ─────────────────────────────────────────
    widget.dealerPriceController.clear();

    // ── 2. Reset All Upload Form Riverpod States ──────────────────────────────
    ref.read(listingStepProvider.notifier).state = 0;
    ref.read(listingProvider.notifier).reset();
    ref.read(editVehicleProvider.notifier).state = (model: null, refreshKey: 0);

    // ── 3. Reset All Media Upload Slot Providers ──────────────────────────────
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

    // ── 4. Redirect Back to Dashboard Tab (Index 0) ───────────────────────────
    ref.read(bottomNavIndexProvider.notifier).state = 0;
    Navigator.of(context).popUntil((route) => route.isFirst);
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

        // reviewState.maybeWhen(
        //   data: (review) =>
        //       _EstimatedPrice(amount: review.data.vehicle.marketPrice),
        //   orElse: () => _EstimatedPrice(amount: listing.estimatedMarketPrice),
        // ),

        const SizedBox(height: 14),
        CommonTextField(
          label: 'Dealer Expected Price',
          hint: 'Enter Dealer Expected Price in ₹',
          controller: widget.dealerPriceController,
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              notifier.update((s) => s.copyWith(dealerExpectedPrice: v)),
        ),
        const SizedBox(height: 20),

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

// class _EstimatedPrice extends StatelessWidget {
//   final num? amount;

//   const _EstimatedPrice({required this.amount});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: UploadColors.successBg,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           const Text('Your Estimated Market Price', style: UploadText.label),
//           const SizedBox(height: 4),
//           Text(
//             amount != null ? '₹${amount!.toStringAsFixed(0)}' : '₹--',
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: UploadColors.success,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
