// lib/features/upload/presentation/pages/vehicle_details_page.dart

import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload_provider.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart';
import 'package:dealer/features/upload/presentation/widgets/identification.dart';
import 'package:dealer/features/upload/presentation/widgets/media_capture_step.dart';
import 'package:dealer/features/upload/presentation/widgets/review_step.dart';
import 'package:dealer/features/upload/presentation/widgets/self_inspection_step.dart';
import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  bool _isSubmittingVehicle = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(getStateProvider.notifier).getState());
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _mileageController.dispose();
    _ownersController.dispose();
    _dealerPriceController.dispose();
    super.dispose();
  }

  void _clearAllControllers() {
    _regNoController.clear();
    _mileageController.clear();
    _ownersController.clear();
    _dealerPriceController.clear();
  }

  void _goToStep(int step) {
    FocusScope.of(context).unfocus();
    ref.read(listingStepProvider.notifier).state = step;

    if (step == 3) {
      final vehicleId = ref.read(listingProvider).vehicleId;
      if (vehicleId != null && vehicleId.isNotEmpty) {
        ref.read(vehicleReviewNotifier.notifier).fetchReview(vehicleId);
      }
    }
  }

  void _handleBack() {
    final step = ref.read(listingStepProvider);
    if (step > 0) {
      _goToStep(step - 1);
    }
  }

  double _conditionScore(String? label) {
    switch (label) {
      case 'Excellent':
        return 5.0;
      case 'Good':
        return 4.0;
      case 'Average':
        return 3.0;
      case 'Poor':
        return 2.0;
      default:
        return 0.0;
    }
  }

  Future<void> _submitVehicleAndProceed() async {
    if (_isSubmittingVehicle) return;

    final listing = ref.read(listingProvider);
    final notifier = ref.read(listingProvider.notifier);

    setState(() => _isSubmittingVehicle = true);

    final request = AddVehicleRequestModel(
      regNo: listing.registrationNumber ?? '',
      makeName: listing.make?.name ?? '',
      modelName: listing.model?.name ?? '',
      variantName: listing.variant?.name ?? '',
      mfgYear: int.tryParse(listing.year ?? '') ?? 0,
      transmission: listing.transmission ?? '',
      fuelType: listing.fuelType ?? '',
      kmDriven: int.tryParse(listing.mileageKm ?? '') ?? 0,
      bodyStyle: listing.bodyStyle ?? '',
      stateId: listing.selectedState?.stateId ?? 0,
      cityId: listing.selectedCity?.cityId ?? 0,
      dealerVehicleInspection: DealerVehicleInspection(
        rc: 0,
        engineCondition: _conditionScore(listing.engineCondition),
        interiorCondition: _conditionScore(listing.interiorCondition),
        exteriorCondition: _conditionScore(listing.exteriorCondition),
        ownerCount: int.tryParse(listing.numberOfOwners ?? '') ?? 0,
        accidentHistory: listing.accidentHistory ?? '',
        remarks: '',
        overallCondition: 0,
      ),
    );

    final response =
        await ref.read(addVehicleData.notifier).addVehicleData(data: request);

    if (!mounted) return;
    setState(() => _isSubmittingVehicle = false);

    if (response == null || !response.success) {
      final errorMsg = ref.read(addVehicleData).maybeWhen(
            error: (msg) => msg,
            orElse: () => 'Could not save vehicle details. Please try again.',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      return;
    }

    notifier.update((s) => s.copyWith(vehicleId: response.data.vehicleId));
    _goToStep(2);
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(listingStepProvider);

    // ── Sync with Edit Form State ───────────────────────────────────────────
    ref.listen(editVehicleProvider, (previous, next) {
      final modelData = next.model;
      if (modelData != null) {
        _regNoController.text = modelData.registrationNumber ?? '';
        _mileageController.text = modelData.mileageKm ?? '';
        _ownersController.text = modelData.numberOfOwners ?? '';
        _dealerPriceController.text = modelData.dealerExpectedPrice ?? '';
      } else {
        _clearAllControllers();
      }
    });

    // ── Auto-clear text controllers when listing state resets ───────────────
    ref.listen(listingProvider, (previous, next) {
      if (next.registrationNumber == null &&
          next.mileageKm == null &&
          next.numberOfOwners == null &&
          next.dealerExpectedPrice == null) {
        _clearAllControllers();
      }
    });

    return PopScope(
      canPop: step == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: UploadColors.background,
        appBar: AppBar(
          backgroundColor: UploadColors.surface,
          elevation: 0.5,
          title: const Text('Upload Vehicle', style: UploadText.pageTitle),
          leading: step == 0
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: UploadColors.textPrimary),
                  onPressed: _handleBack,
                ),
        ),
        body: SafeArea(
          child: IndexedStack(
            index: step,
            children: [
              IdentificationSpecsStep(
                regNoController: _regNoController,
                mileageController: _mileageController,
                onNext: () => _goToStep(1),
              ),
              SelfInspectionStep(
                ownersController: _ownersController,
                onNext: _submitVehicleAndProceed,
              ),
              MediaCaptureStep(onNext: () => _goToStep(3)),
              ReviewStep(dealerPriceController: _dealerPriceController),
            ],
          ),
        ),
      ),
    );
  }
}

class ListingNotifier extends StateNotifier<VehicleListingModel> {
  ListingNotifier() : super(const VehicleListingModel());

  int currentStep = 0;
  static const int totalSteps = 4;

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

final listingStepProvider = StateProvider<int>((ref) => 0);
