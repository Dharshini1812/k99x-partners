// lib/features/upload/presentation/pages/steps/self_inspection_step.dart

import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/upload/presentation/logic/upload_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/identification.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelfInspectionStep extends ConsumerStatefulWidget {
  final TextEditingController ownersController;
  final VoidCallback onNext;

  const SelfInspectionStep({
    super.key,
    required this.ownersController,
    required this.onNext,
  });

  @override
  ConsumerState<SelfInspectionStep> createState() => _SelfInspectionStepState();
}

class _SelfInspectionStepState extends ConsumerState<SelfInspectionStep> {
  final FocusNode _ownersFocus = FocusNode();

  @override
  void dispose() {
    _ownersFocus.dispose();
    super.dispose();
  }

  void _unfocus() {
    _ownersFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);
    final logic = ref.watch(uploadLogic);

    return StepScaffold(
      onNext: () {
        _unfocus();
        widget.onNext();
      },
      nextLabel: 'Next: Vehicle Video',
      children: [
        SectionCard(
          title: 'Self Inspection',
          children: [
            InlineSegmentSelector(
              label: 'Engine Condition',
              value: listing.engineCondition,
              options: logic.kConditionOptions,
              onChanged: (v) {
                _unfocus();
                notifier.update((s) => s.copyWith(engineCondition: v));
              },
            ),
            const SizedBox(height: 14),
            InlineSegmentSelector(
              label: 'Exterior Condition',
              value: listing.exteriorCondition,
              options: logic.kConditionOptions,
              onChanged: (v) {
                _unfocus();
                notifier.update((s) => s.copyWith(exteriorCondition: v));
              },
            ),
            const SizedBox(height: 14),
            InlineSegmentSelector(
              label: 'Interior Condition',
              value: listing.interiorCondition,
              options: logic.kConditionOptions,
              onChanged: (v) {
                _unfocus();
                notifier.update((s) => s.copyWith(interiorCondition: v));
              },
            ),
            const SizedBox(height: 14),
            CommonTextField(
              label: 'Number of Owners',
              hint: 'e.g. 1',
              controller: widget.ownersController,
              focusNode: _ownersFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _unfocus(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(numberOfOwners: v)),
            ),
            const SizedBox(height: 14),
            CommonDropdown<String>(
              label: 'Accident History',
              hint: 'Select Accident History',
              value: listing.accidentHistory,
              options: logic.kAccidentOptions
                  .map((a) => DropdownOption(value: a, label: a))
                  .toList(),
              onChanged: (v) {
                _unfocus();
                notifier.update((s) => s.copyWith(accidentHistory: v));
              },
            ),
          ],
        ),
      ],
    );
  }
}
