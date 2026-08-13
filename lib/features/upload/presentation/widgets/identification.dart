import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/logic/commonlogic.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload_logic.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IdentificationSpecsStep extends ConsumerStatefulWidget {
  final TextEditingController regNoController;
  final TextEditingController mileageController;
  final VoidCallback onNext;

  const IdentificationSpecsStep({
    super.key,
    required this.regNoController,
    required this.mileageController,
    required this.onNext,
  });

  @override
  ConsumerState<IdentificationSpecsStep> createState() =>
      _IdentificationSpecsStepState();
}

class _IdentificationSpecsStepState
    extends ConsumerState<IdentificationSpecsStep> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getMakeProvider.notifier).getMake();
      ref.read(getStateProvider.notifier).getState();
    });

    super.initState();
  }

  Future<void> _autoFillFromEdit(VehicleListingModel listing) async {
    final notifier = ref.read(listingProvider.notifier);

    // ── MAKE → MODEL → VARIANT ─────────────────────────────────────────
    if (listing.make == null && (listing.savedMakeName ?? '').isNotEmpty) {
      await ref.read(getMakeProvider.notifier).getMake();
      final makeState = ref.read(getMakeProvider);
      MakeModel? matchedMake;
      makeState.maybeWhen(
        orElse: () {},
        data: (makes) {
          final match = makes.where((m) =>
              (m.name ?? '').trim().toLowerCase() ==
              listing.savedMakeName!.trim().toLowerCase());
          if (match.isNotEmpty) matchedMake = match.first;
        },
      );
      if (matchedMake != null) {
        notifier.update((s) => s.copyWith(make: matchedMake));

        await ref
            .read(getModelProvider.notifier)
            .getModel(makeId: matchedMake!.sno ?? 0);
        final modelState = ref.read(getModelProvider);
        ModelModel? matchedModel;
        modelState.maybeWhen(
          orElse: () {},
          data: (models) {
            if ((listing.savedModelName ?? '').isEmpty) return;
            final match = models.where((m) =>
                (m.name ?? '').trim().toLowerCase() ==
                listing.savedModelName!.trim().toLowerCase());
            if (match.isNotEmpty) matchedModel = match.first;
          },
        );
        if (matchedModel != null) {
          notifier.update((s) => s.copyWith(model: matchedModel));
          await ref
              .read(getVariantProvider.notifier)
              .getVariants(modelId: matchedModel!.sno ?? 0);
          final variantState = ref.read(getVariantProvider);
          variantState.maybeWhen(
            orElse: () {},
            data: (variants) {
              if ((listing.savedVariantName ?? '').isEmpty) return;
              final match = variants.where((v) =>
                  (v.name ?? '').trim().toLowerCase() ==
                  listing.savedVariantName!.trim().toLowerCase());
              if (match.isNotEmpty) {
                notifier.update((s) => s.copyWith(variant: match.first));
              }
            },
          );
        }
      }
    }
// ── STATE → CITY ───────────────────────────────────────────────────
    if (listing.selectedState == null &&
        (listing.savedStateName ?? '').isNotEmpty) {
      await ref.read(getStateProvider.notifier).getState();
      final stateData = ref.read(getStateProvider);
      StateModel? matchedState;
      stateData.maybeWhen(
        orElse: () {},
        data: (states) {
          final match = states.where((s) =>
              (s.stateName ?? '').trim().toLowerCase() ==
              listing.savedStateName!.trim().toLowerCase());
          if (match.isNotEmpty) matchedState = match.first;
        },
      );
      if (matchedState != null) {
        notifier.update((s) => s.copyWith(selectedState: matchedState));

        await ref
            .read(getCityProvider.notifier)
            .getCity(id: matchedState!.stateId.toString());
        final cityData = ref.read(getCityProvider);
        debugPrint('City state after fetch: $cityData'); // ← add this
        cityData.maybeWhen(
          orElse: () =>
              debugPrint('City fetch not in data state'), // ← add this
          data: (cities) {
            debugPrint(
                'Got ${cities.length} cities, looking for "${listing.savedCityName}"'); // ← add this
            if ((listing.savedCityName ?? '').isEmpty) return;
            final match = cities.where((c) =>
                (c.cityName ?? '').trim().toLowerCase() ==
                listing.savedCityName!.trim().toLowerCase());
            debugPrint('Match found: ${match.isNotEmpty}'); // ← add this
            if (match.isNotEmpty) {
              notifier.update((s) => s.copyWith(selectedCity: match.first));
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = ref.read(uploadLogic);
    final notifier = ref.read(listingProvider.notifier);
    final rcDetails = ref.watch(cLogic).rcDetails;
    ref.listen(editVehicleProvider, (previous, next) {
      if (next.model != null) {
        _autoFillFromEdit(next.model!);
      }
    });

    return StepScaffold(
      onNext: widget.onNext,
      nextLabel: 'Next: Self Inspection',
      children: [
        SectionCard(
          isReg: true,
          onTap: () async {
            await ref.read(cLogic).fetchRc(widget.regNoController.text);
          },
          title: 'Identification',
          children: [
            CommonTextField(
              label: 'Vehicle Registration Number',
              hint: 'Enter vehicle registration number',
              controller: widget.regNoController,
              errorText: ref.watch(cLogic).error,
              onChanged: (value) {
                notifier.update(
                  (s) => s.copyWith(registrationNumber: value),
                );
              },
            ),
            if (rcDetails != null) ...[
              const SizedBox(height: 12),
              _RcReferenceCard(rc: rcDetails),
            ],
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Specifications',
          children: [
            _yearAndMake(logic, notifier),
            _model(logic),
            _variant(logic),
            _mileageAndBodyStyle(logic, notifier),
            _fuelAndTransmission(logic, notifier),
            _stateField(notifier),
            _cityField(logic, notifier),
          ],
        ),
      ],
    );
  }

  Widget _yearAndMake(UploadLogic logic, ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    final makeState = ref.watch(getMakeProvider);

    return Column(
      children: [
        CommonDropdown<String>(
          label: 'Year',
          hint: 'Select Year',
          searchable: true,
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
            searchable: true,
            label: 'Make',
            hint: 'Select Make',
            options: data
                .map((m) => DropdownOption(value: m, label: m.name ?? ''))
                .toList(),
            value: listing.make,
            onChanged: (v) {
              ref.read(getModelProvider.notifier).getModel(makeId: v?.sno ?? 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _model(UploadLogic logic) {
    final listing = ref.watch(listingProvider);
    if (listing.make == null) {
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
        value: listing.model,
        onChanged: (v) {
          ref
              .read(getVariantProvider.notifier)
              .getVariants(modelId: v?.sno ?? 0);
        },
      ),
    );
  }

  Widget _variant(UploadLogic logic) {
    final listing = ref.watch(listingProvider);
    if (listing.model == null) {
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
        searchable: false,
        value: listing.variant,
        options: data
            .map((m) => DropdownOption(value: m, label: m.name ?? ''))
            .toList(),
        onChanged: (v) {},
      ),
    );
  }

  Widget _mileageAndBodyStyle(UploadLogic logic, ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    return Column(
      children: [
        CommonTextField(
          label: 'Mileage (KM)',
          hint: '0',
          controller: widget.mileageController,
          keyboardType: TextInputType.number,
          onChanged: (v) => notifier.update((s) => s.copyWith(mileageKm: v)),
        ),
        const SizedBox(height: 12),
        CommonDropdown<String>(
          label: 'Body Style',
          hint: 'Select Body Style',
          searchable: false,
          value: listing.bodyStyle,
          options: logic.bodyStyleOptions
              .map((b) => DropdownOption(value: b, label: b))
              .toList(),
          onChanged: (v) => notifier.update((s) => s.copyWith(bodyStyle: v)),
        ),
      ],
    );
  }

  Widget _fuelAndTransmission(UploadLogic logic, ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    return Column(
      children: [
        CommonDropdown<String>(
          label: 'Fuel Type',
          hint: 'Select Fuel Type',
          searchable: false,
          value: listing.fuelType,
          options: logic.fuelOptions
              .map((f) => DropdownOption(value: f, label: f))
              .toList(),
          onChanged: (v) => notifier.update((s) => s.copyWith(fuelType: v)),
        ),
        const SizedBox(height: 12),
        CommonDropdown<String>(
          label: 'Transmission',
          hint: 'Select Transmission',
          searchable: false,
          value: listing.transmission,
          options: logic.transmissionOptions
              .map((t) => DropdownOption(value: t, label: t))
              .toList(),
          onChanged: (v) => notifier.update((s) => s.copyWith(transmission: v)),
        ),
      ],
    );
  }

  Widget _stateField(ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    final stateData = ref.watch(getStateProvider);

    return stateData.when(
      initial: () => const CircularProgressIndicator(),
      loading: () => const CircularProgressIndicator(),
      error: (msg) => Text(msg),
      data: (data) => CommonDropdown<StateModel>(
        searchable: true,
        label: 'State',
        hint: 'Select State',
        value: listing.selectedState,
        options: data
            .map((s) => DropdownOption(value: s, label: s.stateName ?? ''))
            .toList(),
        onChanged: (v) {
          notifier.update(
            (s) => s.copyWith(selectedState: v),
          );
          ref.read(getCityProvider.notifier).getCity(id: v?.stateId.toString());
        },
      ),
    );
  }

  Widget _cityField(UploadLogic logic, ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    if (listing.selectedState == null) {
      return const CommonDropdown<CityModel>(
        searchable: true,
        label: 'City',
        hint: 'Select State First',
        enabled: false,
        options: [],
        onChanged: null,
      );
    }

    final cityData = ref.watch(getCityProvider);

    return cityData.when(
      loading: () => const CircularProgressIndicator(),
      error: (msg) => Text(msg),
      initial: () => const SizedBox(),
      data: (data) => CommonDropdown<CityModel>(
        searchable: true,
        label: 'City',
        hint: 'Select City',
        value: listing.selectedCity,
        options: data
            .map((e) => DropdownOption(value: e, label: e.cityName ?? ''))
            .toList(),
        onChanged: (v) => notifier.update((s) => s.copyWith(selectedCity: v)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RC REFERENCE CARD
//
// Why this exists: `_autoFill` in commonlogic.dart tries to auto-select the
// Make/Model/Variant dropdowns by fuzzy-matching the RC's raw strings
// (e.g. makerModel = "1916 LPT DCR53CBC 160B6M5") against your friendly
// dropdown option names. For commercial vehicles / uncommon variants that
// match often fails silently, and the user has no way to know what the RC
// actually said. This card shows the raw values read-only, right under the
// registration field, so the user can eyeball them and pick the correct
// Make / Model / Variant manually below even when auto-fill comes up empty.
//
// Only Registration No. / Maker / Model are shown per the current ask —
// add more _RcRefRow lines below if you want Chassis No., Engine No., or
// Owner count surfaced here too.
// ─────────────────────────────────────────────────────────────────────────────

class _RcReferenceCard extends StatelessWidget {
  final RCDetailsModel rc;

  const _RcReferenceCard({required this.rc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Color(0xFF4F93E3),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'From RC — use this to pick the right Make / Model below',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RcRefRow(label: 'Registration No.', value: rc.registrationNumber),
          const SizedBox(height: 6),
          _RcRefRow(label: 'Maker (RC)', value: rc.makerDescription),
          const SizedBox(height: 6),
          _RcRefRow(label: 'Model (RC)', value: rc.makerModel),
        ],
      ),
    );
  }
}

class _RcRefRow extends StatelessWidget {
  final String label;
  final String? value;

  const _RcRefRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A8699),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            (value == null || value!.trim().isEmpty) ? '—' : value!,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
