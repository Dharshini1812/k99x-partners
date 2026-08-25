import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:dealer/features/upload/data/model/complete_vehicle_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload_provider.dart';
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

  @override
  void initState() {
    super.initState();
  }

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
        content: Text(response.message.isNotEmpty
            ? response.message
            : 'Vehicle listed successfully and sent for review'),
        backgroundColor: Colors.green,
      ),
    );

    // ADAPT: pop back to My Listings, or push a dedicated success page —
    // whichever matches the rest of the app's post-submit flow. Popping
    // twice here assumes ReviewStep sits inside the same
    // VehicleListingPage this whole flow has been built around.
    ref.read(routeService).pushAndRemoveUntil(const BottomNavRoute(), context);
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
        const SizedBox(height: 16),

        // Market price: prefer the server's figure (from the review
        // fetch) once it's loaded, fall back to local state before that.
        reviewState.maybeWhen(
          data: (review) =>
              _EstimatedPrice(amount: review.data.vehicle.marketPrice),
          orElse: () => _EstimatedPrice(amount: listing.estimatedMarketPrice),
        ),

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
          // Fallback while the fetch hasn't started/finished yet, or if
          // it never ran (missing vehicleId) — shows local form state
          // instead of leaving the screen blank.
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
        if (_isCompleting) ...[
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
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
