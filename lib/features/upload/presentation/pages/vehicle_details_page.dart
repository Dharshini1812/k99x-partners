// lib/features/upload/presentation/pages/vehicle_details_page.dart

import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_request_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_response_model.dart';
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
  final String? editVehicleId;
  const VehicleListingPage({
    super.key,
    this.editVehicleId,
  });

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
    if (widget.editVehicleId != null) {
      Future.microtask(() => ref
          .read(editVehicleFetchNotifier.notifier)
          .fetchForEdit(widget.editVehicleId!));
    }
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

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // lib/features/upload/presentation/pages/vehicle_details_page.dart

  Future<void> _submitVehicleAndProceed() async {
    if (_isSubmittingVehicle) return;

    final listing = ref.read(listingProvider);
    final notifier = ref.read(listingProvider.notifier);

    // Resolve vehicleId from widget parameter or listing state
    final String? resolvedId = (widget.editVehicleId != null &&
            widget.editVehicleId!.trim().isNotEmpty)
        ? widget.editVehicleId!.trim()
        : (listing.vehicleId != null && listing.vehicleId!.trim().isNotEmpty)
            ? listing.vehicleId!.trim()
            : null;

    // ── Mandatory Field Validations ──
    if ((listing.registrationNumber ?? '').trim().isEmpty) {
      _showValidationError('Registration number is required.');
      _goToStep(0);
      return;
    }
    if (listing.year == null || (int.tryParse(listing.year!) ?? 0) <= 0) {
      _showValidationError('Please select the manufacturing year.');
      _goToStep(0);
      return;
    }
    if (listing.make == null && (listing.savedMakeName ?? '').trim().isEmpty) {
      _showValidationError('Please select the vehicle make.');
      _goToStep(0);
      return;
    }
    if (listing.model == null &&
        (listing.savedModelName ?? '').trim().isEmpty) {
      _showValidationError('Please select the vehicle model.');
      _goToStep(0);
      return;
    }
    if (listing.variant == null &&
        (listing.savedVariantName ?? '').trim().isEmpty) {
      _showValidationError('Please select the vehicle variant.');
      _goToStep(0);
      return;
    }
    if ((listing.bodyStyle ?? '').trim().isEmpty) {
      _showValidationError('Please select the body style.');
      _goToStep(0);
      return;
    }
    if ((listing.mileageKm ?? '').trim().isEmpty ||
        (int.tryParse(listing.mileageKm!) ?? -1) < 0) {
      _showValidationError('Please enter valid mileage in KM.');
      _goToStep(0);
      return;
    }
    if ((listing.fuelType ?? '').trim().isEmpty) {
      _showValidationError('Please select the fuel type.');
      _goToStep(0);
      return;
    }
    if ((listing.transmission ?? '').trim().isEmpty) {
      _showValidationError('Please select the transmission.');
      _goToStep(0);
      return;
    }
    if ((listing.selectedState?.stateId ?? listing.savedStateId ?? 0) <= 0) {
      _showValidationError('Please select the state.');
      _goToStep(0);
      return;
    }
    if ((listing.selectedCity?.cityId ?? listing.savedCityId ?? 0) <= 0) {
      _showValidationError('Please select the city.');
      _goToStep(0);
      return;
    }
    if ((listing.engineCondition ?? '').trim().isEmpty) {
      _showValidationError('Please select the engine condition.');
      return;
    }
    if ((listing.exteriorCondition ?? '').trim().isEmpty) {
      _showValidationError('Please select the exterior condition.');
      return;
    }
    if ((listing.interiorCondition ?? '').trim().isEmpty) {
      _showValidationError('Please select the interior condition.');
      return;
    }
    if ((listing.numberOfOwners ?? '').trim().isEmpty ||
        (int.tryParse(listing.numberOfOwners!) ?? -1) < 0) {
      _showValidationError('Please enter the number of owners.');
      return;
    }
    if ((listing.accidentHistory ?? '').trim().isEmpty) {
      _showValidationError('Please select the accident history.');
      return;
    }

    setState(() => _isSubmittingVehicle = true);

    // Pass resolvedId as vehicleId if present
    final request = AddVehicleRequestModel(
      vehicleId: resolvedId,
      regNo: listing.registrationNumber!.trim(),
      makeName: listing.make?.name ?? listing.savedMakeName ?? '',
      modelName: listing.model?.name ?? listing.savedModelName ?? '',
      variantName: listing.variant?.name ?? listing.savedVariantName ?? '',
      mfgYear: int.parse(listing.year!),
      transmission: listing.transmission!,
      fuelType: listing.fuelType!,
      kmDriven: int.parse(listing.mileageKm!),
      bodyStyle: listing.bodyStyle!,
      stateId: listing.selectedState?.stateId ?? listing.savedStateId ?? 0,
      cityId: listing.selectedCity?.cityId ?? listing.savedCityId ?? 0,
      dealerVehicleInspection: DealerVehicleInspection(
        rc: 0,
        engineCondition: _conditionScore(listing.engineCondition),
        interiorCondition: _conditionScore(listing.interiorCondition),
        exteriorCondition: _conditionScore(listing.exteriorCondition),
        ownerCount: int.parse(listing.numberOfOwners!),
        accidentHistory: listing.accidentHistory!,
        remarks: '',
        overallCondition: 0,
      ),
    );

    // Call addVehicleData for both add and edit flows
    final response =
        await ref.read(addVehicleData.notifier).addVehicleData(data: request);

    if (!mounted) return;
    setState(() => _isSubmittingVehicle = false);

    if (response == null || !response.success) {
      final errorMsg = response?.message.isNotEmpty == true
          ? response!.message
          : 'Could not save vehicle details. Please try again.';
      _showValidationError(errorMsg);
      return;
    }

    final targetVehicleId = resolvedId ?? (response.data?.vehicleId ?? '');
    notifier.update((s) => s.copyWith(vehicleId: targetVehicleId));
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
          title: Text(
            widget.editVehicleId != null ? 'Edit Vehicle' : 'Upload Vehicle',
            style: UploadText.pageTitle,
          ),
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
