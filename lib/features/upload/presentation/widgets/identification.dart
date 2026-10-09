// lib/features/upload/presentation/widgets/identification.dart

import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/make_model_variant.dart';
import 'package:dealer/core/common/data/model/rc_details.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/logic/commonlogic.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:dealer/features/upload/presentation/logic/upload_logic.dart';
import 'package:dealer/features/upload/presentation/logic/vehicle_edit_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final RegExp _regNoPattern = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$');

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

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
  String? _regNoValidationError;
  bool _regNoTouched = false;

  final FocusNode _regNoFocus = FocusNode();
  final FocusNode _mileageFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getMakeProvider.notifier).getMake();
      ref.read(getStateProvider.notifier).getState();
    });

    if (widget.regNoController.text.isNotEmpty) {
      _validateRegNo(widget.regNoController.text, markTouched: false);
    }
  }

  @override
  void dispose() {
    _regNoFocus.dispose();
    _mileageFocus.dispose();
    super.dispose();
  }

  void _unfocusAll() {
    _regNoFocus.unfocus();
    _mileageFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _validateRegNo(String value, {bool markTouched = true}) {
    final trimmed = value.trim();
    setState(() {
      if (markTouched) _regNoTouched = true;
      if (trimmed.isEmpty) {
        _regNoValidationError = 'Registration number is required';
      } else if (!_regNoPattern.hasMatch(trimmed)) {
        _regNoValidationError =
            'Enter a valid registration number (e.g. TN05AB9381)';
      } else {
        _regNoValidationError = null;
      }
    });
  }

  Future<void> _autoFillFromEdit(VehicleListingModel listing) async {
    final notifier = ref.read(listingProvider.notifier);

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
        cityData.maybeWhen(
          orElse: () {},
          data: (cities) {
            if ((listing.savedCityName ?? '').isEmpty) return;
            final match = cities.where((c) =>
                (c.cityName ?? '').trim().toLowerCase() ==
                listing.savedCityName!.trim().toLowerCase());
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
    final rcFetchError = ref.watch(cLogic).error;

    ref.listen(editVehicleProvider, (previous, next) {
      if (next.model != null) {
        _autoFillFromEdit(next.model!);
        if (next.model!.registrationNumber?.isNotEmpty ?? false) {
          _validateRegNo(next.model!.registrationNumber!, markTouched: false);
        }
      }
    });

    final regNoErrorText = (_regNoTouched && _regNoValidationError != null)
        ? _regNoValidationError
        : rcFetchError;

    return StepScaffold(
      onNext: () {
        _unfocusAll();
        widget.onNext();
      },
      nextLabel: 'Next: Self Inspection',
      nextEnabled: _regNoValidationError == null,
      children: [
        SectionCard(
          isReg: true,
          onTap: () async {
            _unfocusAll();
            await ref.read(cLogic).fetchRc(widget.regNoController.text);
          },
          title: 'Identification',
          children: [
            CommonTextField(
              label: 'Vehicle Registration Number',
              hint: 'Enter vehicle registration number',
              controller: widget.regNoController,
              focusNode: _regNoFocus,
              textInputAction: TextInputAction.next,
              errorText: regNoErrorText,
              inputFormatters: [
                _UpperCaseTextFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                _validateRegNo(value);
                notifier.update(
                  (s) => s.copyWith(registrationNumber: value.toUpperCase()),
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
            _bodyStyle(logic, notifier),
            CommonTextField(
              label: 'Mileage (KM)',
              hint: '0',
              controller: widget.mileageController,
              focusNode: _mileageFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _unfocusAll(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(mileageKm: v)),
            ),
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
          onChanged: (v) {
            _unfocusAll();
            notifier.update((s) => s.copyWith(year: v));
          },
        ),
        const SizedBox(height: 12),
        makeState.maybeWhen(
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
            value: listing.make,
            onChanged: (v) {
              _unfocusAll();
              notifier.update(
                (s) => s.copyWith(
                  make: v,
                  model: null,
                  variant: null,
                ),
              );
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
        value: listing.model,
        onChanged: (v) {
          _unfocusAll();
          ref.read(listingProvider.notifier).update(
                (s) => s.copyWith(
                  model: v,
                  variant: null,
                ),
              );
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
        searchable: true,
        value: listing.variant,
        options: data
            .map((m) => DropdownOption(value: m, label: m.name ?? ''))
            .toList(),
        onChanged: (v) {
          _unfocusAll();
          ref.read(listingProvider.notifier).update(
                (s) => s.copyWith(variant: v),
              );
        },
      ),
    );
  }

  Widget _bodyStyle(UploadLogic logic, ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);

    return CommonDropdown<String>(
      label: 'Body Style',
      hint: 'Select Body Style',
      searchable: false,
      value: listing.bodyStyle,
      options: logic.bodyStyleOptions
          .map((b) => DropdownOption(value: b, label: b))
          .toList(),
      onChanged: (v) {
        _unfocusAll();
        notifier.update((s) => s.copyWith(bodyStyle: v));
      },
    );
  }

  Widget _fuelAndTransmission(UploadLogic logic, ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InlineSegmentSelector(
          label: 'Fuel Type',
          value: listing.fuelType,
          options: logic.fuelOptions,
          onChanged: (v) => notifier.update((s) => s.copyWith(fuelType: v)),
        ),
        const SizedBox(height: 16),
        InlineSegmentSelector(
          label: 'Transmission',
          value: listing.transmission,
          options: logic.transmissionOptions,
          onChanged: (v) => notifier.update((s) => s.copyWith(transmission: v)),
        ),
      ],
    );
  }

  Widget _stateField(ListingNotifier notifier) {
    final listing = ref.watch(listingProvider);
    final stateData = ref.watch(getStateProvider);

    return stateData.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
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
          _unfocusAll();
          notifier.update(
            (s) => s.copyWith(selectedState: v, selectedCity: null),
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
        onChanged: (v) {
          _unfocusAll();
          notifier.update((s) => s.copyWith(selectedCity: v));
        },
      ),
    );
  }
}

class InlineSegmentSelector extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const InlineSegmentSelector({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  Widget _buildItem(String opt, BuildContext context) {
    final isSelected = value?.trim().toLowerCase() == opt.trim().toLowerCase();

    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        onChanged(opt);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFD0D5DD),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          opt,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : const Color(0xFF344054),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 8),

        // ── 2 or 3 Items (e.g. Manual / Automatic)
        if (options.length <= 3)
          Container(
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Row(
              children: options.map((opt) {
                final isSelected =
                    value?.trim().toLowerCase() == opt.trim().toLowerCase();

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      onChanged(opt);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF667085),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )

        // ── 5 Items (Petrol, Diesel, CNG / Electric, Hybrid)
        else if (options.length == 5)
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildItem(options[0], context)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildItem(options[1], context)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildItem(options[2], context)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildItem(options[3], context)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildItem(options[4], context)),
                ],
              ),
            ],
          )

        // ── Generic Fallback Grid
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected =
                  value?.trim().toLowerCase() == opt.trim().toLowerCase();
              return InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  onChanged(opt);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFD0D5DD),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF344054),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

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
                    color: AppColors.primary,
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
