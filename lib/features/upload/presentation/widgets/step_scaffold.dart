// lib/features/upload/presentation/widgets/step_scaffold.dart
//
// Shared layout used by every step: a scrollable body plus a sticky
// "Next" button pinned to the bottom. Extracted so each step file only
// has to worry about its own fields, not layout plumbing.

import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';

class StepScaffold extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onNext;
  final String nextLabel;
  final bool nextEnabled;

  const StepScaffold({
    super.key,
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
                left: UploadSpacing.md,
                right: UploadSpacing.md,
                top: UploadSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + UploadSpacing.md,
              ),
              child: Column(children: children),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(UploadSpacing.md),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: nextEnabled ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UploadColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      UploadColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  nextLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
