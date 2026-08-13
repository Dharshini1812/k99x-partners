// lib/features/upload/presentation/pages/steps/review_step.dart
//
// Step 4 of the listing flow: estimated price, dealer expected price,
// a read-only summary grid, terms checkbox, and submit. Submit is still
// a stub — wire the real repository call where marked below.

import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';

import 'package:dealer/features/upload/presentation/widgets/review_grid.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewStep extends ConsumerWidget {
  final TextEditingController dealerPriceController;

  const ReviewStep({super.key, required this.dealerPriceController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);

    return StepScaffold(
      nextLabel: 'Submit Listing',
      nextEnabled: listing.agreedToTerms,
      onNext: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing submitted (stub)')),
        );
      },
      children: [
        const Text('List Your Vehicle for Sale', style: UploadText.stepTitle),
        const Text(
          'Review all details before submitting your listing.',
          style: UploadText.stepSubtitle,
        ),
        const SizedBox(height: 16),
        _EstimatedPrice(amount: listing.estimatedMarketPrice),
        const SizedBox(height: 14),
        CommonTextField(
          label: 'Dealer Expected Price',
          hint: 'Enter Dealer Expected Price in ₹',
          controller: dealerPriceController,
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              notifier.update((s) => s.copyWith(dealerExpectedPrice: v)),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Vehicle Details',
          children: [
            ReviewGrid(pairs: [
              ('Registration Number', listing.registrationNumber ?? '-'),
              ('Year', listing.year ?? '-'),
              // ('Make', listing.make ?? '-'),
              // ('Model', listing.model ?? '-'),
              // ('Variant/Trim', listing.variant ?? '-'),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: listing.agreedToTerms,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(agreedToTerms: v)),
            ),
            const Expanded(
              child: Text(
                'I agree to the Auction Listing Terms and Conditions and Privacy Policy',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EstimatedPrice extends StatelessWidget {
  final num? amount;

  const _EstimatedPrice({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UploadColors.successBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('Your Estimated Market Price', style: UploadText.label),
          const SizedBox(height: 4),
          Text(
            amount != null ? '₹${amount!.toStringAsFixed(0)}' : '₹--',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: UploadColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
