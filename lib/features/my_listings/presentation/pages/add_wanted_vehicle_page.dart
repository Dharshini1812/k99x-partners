// lib/features/my_listings/presentation/pages/add_wanted_vehicle_page.dart

import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/my_listings/data/model/add_wanted_list_model.dart';
import 'package:dealer/features/my_listings/data/model/wanted_list_model.dart';
import 'package:dealer/features/my_listings/presentation/logic/add_wanted/add_wanted_state.dart';
import 'package:dealer/features/my_listings/presentation/logic/provider.dart';
import 'package:dealer/features/my_listings/presentation/logic/wanted_list/wanted_list_state.dart';
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getMakeProvider.notifier).getMake();
      ref.read(wantedListProvider.notifier).getWantedList();
    });
  }

  @override
  void dispose() {
    _budgetFromController.dispose();
    _budgetToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _unfocus() => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(wantedVehicleProvider.notifier);
    final saveState = ref.watch(wantedSaveProvider);
    final isSaving = saveState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final wantedListState = ref.watch(wantedListProvider);

    ref.listen<WantedSaveState>(wantedSaveProvider, (previous, next) {
      next.maybeWhen(
        data: (r) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(r.message)),
          );
          ref.read(wantedVehicleProvider.notifier).reset();
          _budgetFromController.clear();
          _budgetToController.clear();
          _notesController.clear();
          ref.read(wantedListProvider.notifier).getWantedList();
        },
        error: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        },
        orElse: () {},
      );
    });

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
        child: GestureDetector(
          onTap: _unfocus,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select make, model, and variant from the vehicle database.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
                            onChanged: (v) => notifier
                                .update((s) => s.copyWith(budgetFrom: v)),
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
                    onPressed: isSaving ? null : () => _saveListing(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F6FED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Wanted Listing',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                _wantedListSection(wantedListState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _make(WantedVehicleNotifier notifier) {
    final wanted = ref.watch(wantedVehicleProvider);
    final makeState = ref.watch(getMakeProvider);

    return makeState.maybeWhen(
      orElse: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
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
          _unfocus();
          notifier.update(
            (s) => s.copyWith(make: v, clearModel: true, clearVariant: true),
          );
          ref.read(getModelProvider.notifier).getModel(makeId: v?.sno ?? 0);
        },
      ),
    );
  }

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
      orElse: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
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
          _unfocus();
          notifier.update((s) => s.copyWith(model: v, clearVariant: true));
          ref
              .read(getVariantProvider.notifier)
              .getVariants(modelId: v?.sno ?? 0);
        },
      ),
    );
  }

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
      orElse: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (message) => Text(message),
      data: (data) => CommonDropdown<VariantModel>(
        label: 'Variant',
        hint: 'Select Variant',
        value: wanted.variant,
        options: data
            .map((m) => DropdownOption(value: m, label: m.name ?? ''))
            .toList(),
        onChanged: (v) {
          _unfocus();
          notifier.update((s) => s.copyWith(variant: v));
        },
      ),
    );
  }

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
            _unfocus();
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

  String _formatApiDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  void _saveListing(BuildContext context) {
    _unfocus();
    final wanted = ref.read(wantedVehicleProvider);

    if (wanted.make == null ||
        wanted.model == null ||
        wanted.variant == null ||
        _budgetFromController.text.trim().isEmpty ||
        _budgetToController.text.trim().isEmpty ||
        wanted.neededBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final budgetFrom = double.tryParse(_budgetFromController.text.trim());
    final budgetTo = double.tryParse(_budgetToController.text.trim());
    if (budgetFrom == null || budgetTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget must be a valid number')),
      );
      return;
    }

    final request = WantedListingRequestModel(
      vehicleType: 'car',
      makeName: wanted.make!.name ?? '',
      modelName: wanted.model!.name ?? '',
      variantName: wanted.variant!.name ?? '',
      budgetFrom: budgetFrom,
      budgetTo: budgetTo,
      neededBy: _formatApiDate(wanted.neededBy!),
      notes: _notesController.text.trim(),
    );

    ref.read(wantedSaveProvider.notifier).save(request);
  }

  Widget _wantedListSection(WantedListState state) {
    return state.maybeWhen(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (msg) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          msg.isEmpty ? 'Failed to load wanted list' : msg,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
      data: (response) {
        final items = response.data?.wantedList ?? const [];
        final openCount = response.data?.stats.open ?? items.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Wanted Listings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$openCount Open',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No wanted vehicles yet',
                    style: TextStyle(color: Color(0xFF9AA0A6)),
                  ),
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) => _wantedCard(items[index]),
              ),
          ],
        );
      },
    );
  }

  Widget _wantedCard(WantedListModel item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${item.make} ${item.model} ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextSpan(
                        text: item.variant,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _capitalize(item.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(item.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _wantedCardDetail(
                  'Budget',
                  '₹${item.budgetFrom.toStringAsFixed(0)} - ₹${item.budgetTo.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _wantedCardDetail(
                  'Needed By',
                  (item.neededBy != null && item.neededBy!.isNotEmpty)
                      ? item.neededBy!
                      : '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wantedCardDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFF27AE60);
      case 'MATCHED':
        return const Color(0xFF2E86DE);
      case 'CLOSED':
        return const Color(0xFF9AA0A6);
      default:
        return const Color(0xFF9AA0A6);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
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

  void reset() => state = const WantedVehicleState();
}

final wantedVehicleProvider =
    StateNotifierProvider<WantedVehicleNotifier, WantedVehicleState>(
  (_) => WantedVehicleNotifier(),
);
