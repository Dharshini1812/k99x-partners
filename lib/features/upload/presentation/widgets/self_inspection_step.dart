// lib/features/upload/presentation/pages/steps/self_inspection_step.dart
//
// Step 2 of the listing flow: condition ratings, owner count, accident
// history. Same fields and options as the original inline version.

import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/upload/presentation/logic/upload_logic.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:dealer/features/upload/presentation/widgets/section_card.dart';
import 'package:dealer/features/upload/presentation/widgets/step_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelfInspectionStep extends ConsumerWidget {
  final TextEditingController ownersController;
  final VoidCallback onNext;

  const SelfInspectionStep({
    super.key,
    required this.ownersController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider);
    final notifier = ref.read(listingProvider.notifier);
    final logic = ref.watch(uploadLogic);

    return StepScaffold(
      onNext: onNext,
      nextLabel: 'Next: Vehicle Video',
      children: [
        SectionCard(
          title: 'Self Inspection',
          children: [
            CommonDropdown<String>(
              label: 'Engine Condition',
              hint: 'Select',
              value: listing.engineCondition,
              options: logic.kConditionOptions
                  .map((c) => DropdownOption(value: c, label: c))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(engineCondition: v)),
              searchable: false,
            ),
            const SizedBox(height: 12),
            CommonDropdown<String>(
              label: 'Exterior Condition',
              hint: 'Select',
              value: listing.exteriorCondition,
              options: logic.kConditionOptions
                  .map((c) => DropdownOption(value: c, label: c))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(exteriorCondition: v)),
              searchable: false,
            ),
            const SizedBox(height: 12),
            CommonDropdown<String>(
              label: 'Interior Condition',
              hint: 'Select',
              value: listing.interiorCondition,
              options: logic.kConditionOptions
                  .map((c) => DropdownOption(value: c, label: c))
                  .toList(),
              onChanged: (v) =>
                  notifier.update((s) => s.copyWith(interiorCondition: v)),
              searchable: false,
            ),
            const SizedBox(height: 12),
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
              options: logic.kAccidentOptions
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
