// lib/features/upload/presentation/pages/vehicle_listing_page.dart
//
// Entry point for the 4-step vehicle listing flow. This file only
// owns the app bar, back-button/PopScope handling, the text controllers,
// and the IndexedStack that switches between steps — all step-specific
// UI now lives in pages/steps/*.dart.

import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
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

  void _goToStep(int step) =>
      ref.read(listingStepProvider.notifier).state = step;

  void _handleBack() {
    final step = ref.read(listingStepProvider);
    if (step == 0) {
      Navigator.maybePop(context);
    } else {
      _goToStep(step - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(listingStepProvider);

    // ─────────────────────────────────────────────────────────────
    // ✅ UPDATE: READ THE MODEL PROPERTY
    // ─────────────────────────────────────────────────────────────
    ref.listen(editVehicleProvider, (previous, next) {
      final modelData = next.model; // Extract the actual vehicle data

      if (modelData != null) {
        // Edit mode: Populating controller text with data.
        _regNoController.text = modelData.registrationNumber ?? '';
        _mileageController.text = modelData.mileageKm ?? '';
        _ownersController.text = modelData.numberOfOwners ?? '';
        _dealerPriceController.text = modelData.dealerExpectedPrice ?? '';
      } else {
        // Clear mode: Clear controllers.
        _regNoController.clear();
        _mileageController.clear();
        _ownersController.clear();
        _dealerPriceController.clear();
      }
    });

    return PopScope(
      canPop: false,
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: UploadColors.textPrimary),
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
                onNext: () => _goToStep(2),
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

// lib/features/upload/presentation/logic/listing_provider.dart
//
// State for the listing flow. Unchanged from the original — just kept
// as its own file since it's already separate from the widget tree.

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
