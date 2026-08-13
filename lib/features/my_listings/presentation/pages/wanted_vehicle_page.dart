// lib/features/wanted/presentation/pages/add_wanted_vehicle_page.dart
//
// "Add Wanted Vehicle" form. Vehicle Requirement section reuses the exact
// same cascading Make → Model → Variant pattern as
// identification_specs_step.dart: CommonDropdown<T> + DropdownOption<T>,
// driven by getMakeProvider → getModelProvider → getVariantProvider, with
// each dropdown disabled ("Select X First") until its parent is picked.

import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddWantedVehiclePage extends ConsumerStatefulWidget {
  const AddWantedVehiclePage({super.key});

  @override
  ConsumerState<AddWantedVehiclePage> createState() =>
      _AddWantedVehiclePageState();
}

class _AddWantedVehiclePageState extends ConsumerState<AddWantedVehiclePage> {
  final _budgetFromController = TextEditingController();
  final _budgetToController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getMakeProvider.notifier).getMake();
    });
    super.initState();
  }

  @override
  void dispose() {
    _budgetFromController.dispose();
    _budgetToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(wantedVehicleProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Add Wanted Vehicle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select make, model, and variant from the vehicle API.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Vehicle Requirement',
                children: [
                  _make(notifier),
                  const SizedBox(height: 12),
                  _model(notifier),
                  const SizedBox(height: 12),
                  _variant(notifier),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Details',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: 'Budget From',
                          hint: 'Minimum price',
                          controller: _budgetFromController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              notifier.update((s) => s.copyWith(budgetFrom: v)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonTextField(
                          label: 'Budget To',
                          hint: 'Maximum price',
                          controller: _budgetToController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              notifier.update((s) => s.copyWith(budgetTo: v)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _neededByField(notifier),
                  const SizedBox(height: 12),
                  CommonTextField(
                    label: 'Notes',
                    hint:
                        'Color, fuel type, kilometers, or customer requirement',
                    controller: _notesController,
                    maxLines: 4,
                    onChanged: (v) =>
                        notifier.update((s) => s.copyWith(notes: v)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveListing(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6FED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save Wanted Listing',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Make ──────────────────────────────────────────────────────────────
  // Picking a Make: stores it in wantedVehicleProvider, clears any
  // previously-picked Model/Variant, and triggers the Model fetch —
  // same chain as _yearAndMake() in identification_specs_step.dart.
  Widget _make(WantedVehicleNotifier notifier) {
    final wanted = ref.watch(wantedVehicleProvider);
    final makeState = ref.watch(getMakeProvider);

    return makeState.maybeWhen(
      orElse: () => const CircularProgressIndicator(),
      error: (message) => Text(message),
      data: (data) => CommonDropdown<MakeModel>(
        searchable: true,
        label: 'Make',
        hint: 'Select Make',
        options: data
            .map((m) => DropdownOption(value: m, label: m.name ?? ''))
            .toList(),
        value: wanted.make,
        onChanged: (v) {
          notifier.update(
            (s) => s.copyWith(make: v, clearModel: true, clearVariant: true),
          );
          ref.read(getModelProvider.notifier).getModel(makeId: v?.sno ?? 0);
        },
      ),
    );
  }

  // ── Model ─────────────────────────────────────────────────────────────
  // Disabled with "Select Make First" until wanted.make is set — same
  // pattern as _model() in identification_specs_step.dart.
  Widget _model(WantedVehicleNotifier notifier) {
    final wanted = ref.watch(wantedVehicleProvider);

    if (wanted.make == null) {
      return const CommonDropdown<ModelModel>(
        searchable: true,
        label: 'Model',
        hint: 'Select Make First',
        enabled: false,
        options: [],
        onChanged: null,
      );
    }

    final modelState = ref.watch(getModelProvider);
    return modelState.maybeWhen(
      orElse: () => const CircularProgressIndicator(),
      error: (message) => Text(message),
      data: (data) => CommonDropdown<ModelModel>(
        searchable: true,
        label: 'Model',
        hint: 'Select Model',
        options: data
            .map((m) => DropdownOption(value: m, label: m.name ?? ''))
            .toList(),
        value: wanted.model,
        onChanged: (v) {
          notifier.update((s) => s.copyWith(model: v, clearVariant: true));
          ref
              .read(getVariantProvider.notifier)
              .getVariants(modelId: v?.sno ?? 0);
        },
      ),
    );
  }

  // ── Variant ───────────────────────────────────────────────────────────
  // Disabled with "Select Model First" until wanted.model is set — same
  // pattern as _variant() in identification_specs_step.dart.
  Widget _variant(WantedVehicleNotifier notifier) {
    final wanted = ref.watch(wantedVehicleProvider);

    if (wanted.model == null) {
      return const CommonDropdown<VariantModel>(
        searchable: true,
        label: 'Variant',
        hint: 'Select Model First',
        enabled: false,
        options: [],
        onChanged: null,
      );
    }

    final variantState = ref.watch(getVariantProvider);
    return variantState.maybeWhen(
      orElse: () => const CircularProgressIndicator(),
      error: (message) => Text(message),
      data: (data) => CommonDropdown<VariantModel>(
        label: 'Variant',
        hint: 'Select Variant',
        value: wanted.variant,
        options: data
            .map((m) => DropdownOption(value: m, label: m.name ?? ''))
            .toList(),
        onChanged: (v) => notifier.update((s) => s.copyWith(variant: v)),
      ),
    );
  }

  // ── Needed By ─────────────────────────────────────────────────────────
  // No CommonDateField was visible in what you shared, so this is a
  // custom field styled to match CommonTextField's look. If you already
  // have a shared date-field widget, swap this call for that directly.
  Widget _neededByField(WantedVehicleNotifier notifier) {
    final wanted = ref.watch(wantedVehicleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Needed By',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: wanted.neededBy ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              notifier.update((s) => s.copyWith(neededBy: picked));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    wanted.neededBy != null
                        ? _formatDate(wanted.neededBy!)
                        : 'dd/mm/yyyy',
                    style: TextStyle(
                      fontSize: 14,
                      color: wanted.neededBy != null
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  void _saveListing(BuildContext context) {}
}

class WantedVehicleState {
  final MakeModel? make;
  final ModelModel? model;
  final VariantModel? variant;
  final String? budgetFrom;
  final String? budgetTo;
  final DateTime? neededBy;
  final String? notes;

  const WantedVehicleState({
    this.make,
    this.model,
    this.variant,
    this.budgetFrom,
    this.budgetTo,
    this.neededBy,
    this.notes,
  });

  /// Reference fields (make/model/variant) use explicit `clearX` flags
  /// rather than plain `??` fallbacks, since cascading the dropdowns needs
  /// to be able to reset a field to null (e.g. clearing Model when Make
  /// changes) — a bare `field ?? this.field` can't express "set to null".
  WantedVehicleState copyWith({
    MakeModel? make,
    bool clearMake = false,
    ModelModel? model,
    bool clearModel = false,
    VariantModel? variant,
    bool clearVariant = false,
    String? budgetFrom,
    String? budgetTo,
    DateTime? neededBy,
    String? notes,
  }) {
    return WantedVehicleState(
      make: clearMake ? null : (make ?? this.make),
      model: clearModel ? null : (model ?? this.model),
      variant: clearVariant ? null : (variant ?? this.variant),
      budgetFrom: budgetFrom ?? this.budgetFrom,
      budgetTo: budgetTo ?? this.budgetTo,
      neededBy: neededBy ?? this.neededBy,
      notes: notes ?? this.notes,
    );
  }
}

class WantedVehicleNotifier extends StateNotifier<WantedVehicleState> {
  WantedVehicleNotifier() : super(const WantedVehicleState());

  void update(WantedVehicleState Function(WantedVehicleState) fn) {
    state = fn(state);
  }

  void reset() {
    state = const WantedVehicleState();
  }
}

final wantedVehicleProvider =
    StateNotifierProvider<WantedVehicleNotifier, WantedVehicleState>(
  (_) => WantedVehicleNotifier(),
);
