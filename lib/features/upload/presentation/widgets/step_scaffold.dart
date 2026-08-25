// lib/features/upload/presentation/widgets/step_scaffold.dart

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(UploadSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
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
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (nextEnabled) onNext();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UploadColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        UploadColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
      ),
    );
  }
}
