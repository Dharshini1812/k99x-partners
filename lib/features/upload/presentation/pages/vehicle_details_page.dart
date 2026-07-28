// lib/features/upload/presentation/pages/vehicle_listing_page.dart

import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class VehicleListingPage extends ConsumerStatefulWidget {
  const VehicleListingPage({super.key});

  @override
  ConsumerState<VehicleListingPage> createState() => _VehicleListingPageState();
}

class _VehicleListingPageState extends ConsumerState<VehicleListingPage> {
  final _regNoController = TextEditingController();
  final _mileageController = TextEditingController();
  final _ownersController = TextEditingController();
  final _dealerPriceController = TextEditingController();

  @override
  void dispose() {
    _regNoController.dispose();
    _mileageController.dispose();
    _ownersController.dispose();
    _dealerPriceController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final step = ref.read(listingStepProvider);
    if (step == 0) {
      Navigator.maybePop(context);
    } else {
      ref.read(listingStepProvider.notifier).state = step - 1;
    }
  }

  @override
  void initState() {
    Future.microtask(() {
      ref.read(getStateProvider.notifier).getState();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(listingStepProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        // Your custom back logic
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'Upload Vehicle',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (step == 0) {
                Navigator.maybePop(context);
              } else {
                ref.read(listingStepProvider.notifier).state = step - 1;
              }
            },
          ),
        ),
        body: SafeArea(
          child: IndexedStack(
            index: step,
            children: [
              _IdentificationAndSpecsStep(
                regNoController: _regNoController,
                mileageController: _mileageController,
              ),
              _SelfInspectionStep(ownersController: _ownersController),
              const _MediaCaptureStep(),
              _ReviewStep(dealerPriceController: _dealerPriceController),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// STEP 1 — Identification + Specifications
// ---------------------------------------------------------------

class _IdentificationAndSpecsStep extends ConsumerStatefulWidget {
  final TextEditingController regNoController;
  final TextEditingController mileageController;
  const _IdentificationAndSpecsStep({
    required this.regNoController,
    required this.mileageController,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __IdentificationAndSpecsStepState();
}

class __IdentificationAndSpecsStepState
    extends ConsumerState<_IdentificationAndSpecsStep> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getMakeProvider.notifier).getMake();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stateData = ref.watch(getStateProvider);
    final cityData = ref.watch(getCityProvider);
    final listing = ref.watch(listingProvider);
    final logic = ref.read(uploadLogic);
    final notifier = ref.read(listingProvider.notifier);
    final makeState = ref.watch(getMakeProvider);
    final modelState = ref.watch(getModelProvider);
    final variantState = ref.watch(getVariantProvider);

    return _StepScaffold(
      onNext: () => ref.read(listingStepProvider.notifier).state = 1,
      nextLabel: 'Next: Self Inspection',
      children: [
        _SectionCard(
          title: 'Identification',
          children: [
            CommonTextField(
              label: 'Vehicle Registration Number',
              hint: 'Enter vehicle registration number',
              controller: widget.regNoController,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(registrationNumber: v)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Specifications',
          children: [
            Column(
              children: [
                CommonDropdown<String>(
                  label: 'Year',
                  hint: 'Select Year',
                  value: listing.year,
                  options: logic.yearOptions
                      .map((y) => DropdownOption(value: y, label: y))
                      .toList(),
                  onChanged: (v) => notifier.update((s) => s.copyWith(year: v)),
                ),
                const SizedBox(height: 12),
                makeState.maybeWhen(
                  orElse: () => const CircularProgressIndicator(),
                  error: (message) => Text(message),
                  data: (data) => CommonDropdown<MakeModel>(
                    label: 'Make',
                    hint: 'Select Make',
                    options: data
                        .map((m) =>
                            DropdownOption(value: m, label: m.name ?? ''))
                        .toList(),
                    onChanged: (v) {
                      logic.setMake(v);
                      ref
                          .read(getModelProvider.notifier)
                          .getModel(makeId: v?.sno ?? 0);
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 14),
            if (logic.make == null)
              const CommonDropdown<ModelModel>(
                label: 'Model',
                hint: 'Select Model First',
                enabled: false,
                options: [],
                onChanged: null,
              )
            else
              modelState.maybeWhen(
                orElse: () => const CircularProgressIndicator(),
                error: (message) => Text(message),
                data: (data) => CommonDropdown<ModelModel>(
                  label: 'Model',
                  hint: 'Select Model',
                  options: data
                      .map((m) => DropdownOption(value: m, label: m.name ?? ''))
                      .toList(),
                  onChanged: (v) => {
                    logic.setModel(v),
                    ref
                        .read(getVariantProvider.notifier)
                        .getVariants(modelId: v?.sno ?? 0),
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (logic.model == null)
              const CommonDropdown<VariantModel>(
                label: 'Variant',
                hint: 'Select Variant First',
                enabled: false,
                options: [],
                onChanged: null,
              )
            else
              variantState.maybeWhen(
                orElse: () => const CircularProgressIndicator(),
                error: (message) => Text(message),
                data: (data) => CommonDropdown<VariantModel>(
                  label: 'Variant',
                  hint: 'Select Variant',
                  options: data
                      .map((m) => DropdownOption(value: m, label: m.name ?? ''))
                      .toList(),
                  onChanged: (v) => {},
                ),
              ),
            const SizedBox(height: 12),
            CommonTextField(
              label: 'Mileage (KM)',
              hint: '0',
              controller: widget.mileageController,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(mileageKm: v)),
            ),
            const SizedBox(width: 12),
            CommonDropdown<String>(
              label: 'Body Style',
              hint: 'Select Body Style',
              value: listing.bodyStyle,
              options: logic.bodyStyleOptions
                  .map((b) => DropdownOption(value: b, label: b))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(bodyStyle: v)),
            ),
            const SizedBox(height: 12),
            CommonDropdown<String>(
              label: 'Fuel Type',
              hint: 'Select Fuel Type',
              value: listing.fuelType,
              options: logic.fuelOptions
                  .map((f) => DropdownOption(value: f, label: f))
                  .toList(),
              errorText: listing.fuelType == null
                  ? 'Please select the fuel type'
                  : null,
              onChanged: (v) => notifier.update((s) => s.copyWith(fuelType: v)),
            ),
            const SizedBox(width: 12),
            CommonDropdown<String>(
              label: 'Transmission',
              hint: 'Select Transmission',
              value: listing.transmission,
              options: logic.transmissionOptions
                  .map((t) => DropdownOption(value: t, label: t))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(transmission: v)),
            ),
            const SizedBox(height: 12),
            stateData.when(
              initial: () => const CircularProgressIndicator(),
              loading: () => const CircularProgressIndicator(),
              error: (msg) => Text(msg),
              data: (data) {
                return CommonDropdown<StateModel>(
                  label: 'State',
                  hint: 'Select State',
                  value: listing.selectedState,
                  options: data
                      .map((s) => DropdownOption(
                            value: s,
                            label: s.stateName ?? '',
                          ))
                      .toList(),
                  onChanged: (v) {
                    logic.setState(v);

                    ref
                        .read(getCityProvider.notifier)
                        .getCity(id: v?.eqStateId.toString());
                  },
                );
              },
            ),
            const SizedBox(width: 12),
            if (logic.state == null)
              const CommonDropdown<CityModel>(
                label: 'City',
                hint: 'Select State First',
                enabled: false,
                options: [],
                onChanged: null,
              )
            else
              cityData.when(
                loading: () => const CircularProgressIndicator(),
                error: (msg) => Text(msg),
                initial: () =>
                    const SizedBox(), // if your AsyncValue has initial
                data: (data) {
                  return CommonDropdown<CityModel>(
                    label: 'City',
                    hint: 'Select City',
                    value: listing.selectedCity,
                    options: data
                        .map((e) => DropdownOption(
                              value: e,
                              label: e.cityName ?? '',
                            ))
                        .toList(),
                    onChanged: (v) {
                      notifier.update(
                        (s) => s.copyWith(selectedCity: v),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// STEP 2 — Self Inspection
// ---------------------------------------------------------------
class _SelfInspectionStep extends ConsumerWidget {
  final TextEditingController ownersController;

  const _SelfInspectionStep({required this.ownersController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);

    const conditionOptions = ['Excellent', 'Good', 'Average', 'Poor'];
    const accidentOptions = [
      'No Accidents',
      'Minor Accident',
      'Major Accident'
    ];

    return _StepScaffold(
      onNext: () => ref.read(listingStepProvider.notifier).state = 2,
      nextLabel: 'Next: Vehicle Video',
      children: [
        _SectionCard(
          title: 'Self Inspection',
          children: [
            CommonDropdown<String>(
              label: 'Engine Condition',
              hint: 'Select',
              value: listing.engineCondition,
              options: conditionOptions
                  .map((c) => DropdownOption(value: c, label: c))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(engineCondition: v)),
            ),
            const SizedBox(width: 12),
            CommonDropdown<String>(
              label: 'Exterior Condition',
              hint: 'Select',
              value: listing.exteriorCondition,
              options: conditionOptions
                  .map((c) => DropdownOption(value: c, label: c))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(exteriorCondition: v)),
            ),
            const SizedBox(height: 12),
            CommonDropdown<String>(
              label: 'Interior Condition',
              hint: 'Select',
              value: listing.interiorCondition,
              options: conditionOptions
                  .map((c) => DropdownOption(value: c, label: c))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(interiorCondition: v)),
            ),
            const SizedBox(width: 12),
            CommonTextField(
              label: 'Number of Owners',
              hint: 'e.g. 1',
              controller: ownersController,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(numberOfOwners: v)),
            ),
            const SizedBox(height: 12),
            CommonDropdown<String>(
              label: 'Accident History',
              hint: 'Select',
              value: listing.accidentHistory,
              options: accidentOptions
                  .map((a) => DropdownOption(value: a, label: a))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(accidentHistory: v)),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// STEP 3 — Photos & Videos
// ---------------------------------------------------------------
class _MediaCaptureStep extends ConsumerWidget {
  const _MediaCaptureStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);
    final picker = ImagePicker();

    Future<void> captureImage(void Function(String path) onPicked) async {
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file != null) onPicked(file.path);
    }

    Future<void> uploadImage(void Function(String path) onPicked) async {
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) onPicked(file.path);
    }

    Future<void> captureVideo(void Function(String path) onPicked) async {
      final file = await picker.pickVideo(source: ImageSource.camera);
      if (file != null) onPicked(file.path);
    }

    Future<void> uploadVideo(void Function(String path) onPicked) async {
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) onPicked(file.path);
    }

    return _StepScaffold(
      onNext: () => ref.read(listingStepProvider.notifier).state = 3,
      nextLabel: 'Next: Submit for Review',
      children: [
        const Text('List Your Vehicle for Sale',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Text(
          'Capture essential photos and videos of your vehicle for buyers.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MediaCard(
                title: 'Front Vehicle Image',
                subtitle: "Capture a clear image of the car's front.",
                isVideo: false,
                path: listing.frontImagePath,
                onCapture: () => captureImage((p) =>
                    notifier.update((s) => s.copyWith(frontImagePath: p))),
                onUpload: () => uploadImage((p) =>
                    notifier.update((s) => s.copyWith(frontImagePath: p))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MediaCard(
                title: 'Vehicle Odometer Image',
                subtitle: "Capture a clear image of the car's odometer.",
                isVideo: false,
                path: listing.odometerImagePath,
                onCapture: () => captureImage((p) =>
                    notifier.update((s) => s.copyWith(odometerImagePath: p))),
                onUpload: () => uploadImage((p) =>
                    notifier.update((s) => s.copyWith(odometerImagePath: p))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MediaCard(
                title: 'Vehicle Exterior',
                subtitle: 'Walk around the entire car, showing all sides.',
                isVideo: true,
                path: listing.exteriorVideoPath,
                onCapture: () => captureVideo((p) =>
                    notifier.update((s) => s.copyWith(exteriorVideoPath: p))),
                onUpload: () => uploadVideo((p) =>
                    notifier.update((s) => s.copyWith(exteriorVideoPath: p))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MediaCard(
                title: 'Vehicle Interior',
                subtitle: 'Pan across the dashboard, seats, and cabin.',
                isVideo: true,
                path: listing.interiorVideoPath,
                onCapture: () => captureVideo((p) =>
                    notifier.update((s) => s.copyWith(interiorVideoPath: p))),
                onUpload: () => uploadVideo((p) =>
                    notifier.update((s) => s.copyWith(interiorVideoPath: p))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MediaCard(
                title: 'Vehicle Engine Bay',
                subtitle: 'Show engine running if possible.',
                isVideo: true,
                path: listing.engineBayVideoPath,
                onCapture: () => captureVideo((p) =>
                    notifier.update((s) => s.copyWith(engineBayVideoPath: p))),
                onUpload: () => uploadVideo((p) =>
                    notifier.update((s) => s.copyWith(engineBayVideoPath: p))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MediaCard(
                title: 'Vehicle Tyres',
                subtitle: 'Close-up of each tyre.',
                isVideo: true,
                path: listing.tyresVideoPath,
                onCapture: () => captureVideo((p) =>
                    notifier.update((s) => s.copyWith(tyresVideoPath: p))),
                onUpload: () => uploadVideo((p) =>
                    notifier.update((s) => s.copyWith(tyresVideoPath: p))),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isVideo;
  final String? path;
  final VoidCallback onCapture;
  final VoidCallback onUpload; // NEW

  const _MediaCard({
    required this.title,
    required this.subtitle,
    required this.isVideo,
    required this.path,
    required this.onCapture,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = path != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.4,
            child: Container(
              decoration: BoxDecoration(
                color: hasMedia ? Colors.black : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(10),
                border: hasMedia
                    ? null
                    : Border.all(color: const Color(0xFFD0D5DD)),
              ),
              child: hasMedia
                  ? Center(
                      child: Icon(
                        isVideo ? Icons.play_circle_fill : Icons.check_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    )
                  : Center(
                      child: Icon(
                        isVideo
                            ? Icons.videocam_outlined
                            : Icons.camera_alt_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          if (!hasMedia) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCapture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(isVideo ? 'Capture Video' : 'Capture Photo'),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: onUpload,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isVideo ? 'or  Upload Video' : 'or  Upload Photo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // caller wires this to clear the path in state
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Remove'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// STEP 4 — Review & Submit
// ---------------------------------------------------------------
class _ReviewStep extends ConsumerWidget {
  final TextEditingController dealerPriceController;

  const _ReviewStep({required this.dealerPriceController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);

    return _StepScaffold(
      nextLabel: 'Submit Listing',
      nextEnabled: listing.agreedToTerms,
      onNext: () async {
        // TODO: wire real submit call here, e.g.:
        // await ref.read(listingRepositoryProvider).submit(listing);
        // then upload media files separately and attach returned URLs
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing submitted (stub)')),
        );
      },
      children: [
        const Text(
          'List Your Vehicle for Sale',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const Text(
          'Review all details before submitting your listing.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text('Your Estimated Market Price',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                listing.estimatedMarketPrice != null
                    ? '₹${listing.estimatedMarketPrice!.toStringAsFixed(0)}'
                    : '₹--',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
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
        _SectionCard(
          title: 'Vehicle Details',
          children: [
            _ReviewGrid(pairs: [
              ('Registration Number', listing.registrationNumber ?? '-'),
              ('Year', listing.year ?? '-'),
              ('Make', listing.make ?? '-'),
              ('Model', listing.model ?? '-'),
              ('Variant/Trim', listing.variant ?? '-'),
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

class _ReviewGrid extends StatelessWidget {
  final List<(String, String)> pairs;
  const _ReviewGrid({required this.pairs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 14,
      children: pairs.map((p) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.$1,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(p.$2,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------
// Shared step scaffold (scrollable content + sticky bottom button)
// ---------------------------------------------------------------
class _StepScaffold extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onNext;
  final String nextLabel;
  final bool nextEnabled;

  const _StepScaffold({
    required this.children,
    required this.onNext,
    required this.nextLabel,
    this.nextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 14,
              ),
              child: Column(children: children),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: nextEnabled ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  nextLabel,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 2, width: 60, color: Colors.blue),
          const SizedBox(height: 16),
          ...children.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: c,
              )),
        ],
      ),
    );
  }
} // lib/features/upload/presentation/logic/listing_provider.dart

class ListingNotifier extends StateNotifier<VehicleListingModel> {
  ListingNotifier() : super(const VehicleListingModel());

  int currentStep = 0;
  static const int totalSteps =
      4; // Identification+Specs, Inspection, Media, Review

  void update(VehicleListingModel Function(VehicleListingModel) updater) {
    state = updater(state);
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) currentStep++;
  }

  void previousStep() {
    if (currentStep > 0) currentStep--;
  }

  void reset() {
    state = const VehicleListingModel();
    currentStep = 0;
  }
}

final listingProvider =
    StateNotifierProvider<ListingNotifier, VehicleListingModel>(
  (ref) => ListingNotifier(),
);

// Local step tracker as its own provider so widgets can watch it independently
final listingStepProvider = StateProvider<int>((ref) => 0);
