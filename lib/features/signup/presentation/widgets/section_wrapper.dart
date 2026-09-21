// lib/features/onboarding/presentation/widgets/section_wrapper.dart
//
// The collapsible "step" card. The step number is now a small round badge
// instead of bare text, so the three states (pending / active / done) read
// as clearly distinct states rather than a color change on plain digits.

import 'package:flutter/material.dart';

const _kDark = Color(0xFF12142B);
const _kGrey = Color(0xFF8A8FA6);
const _kGreen = Color(0xFF1FAA59);
const _kGreenTint = Color(0xFFE7F7EE);
const _kAccentBlue = Color(0xFF4C3DE0);
const _kPendingTint = Color(0xFFF1EFE8);
const _kPendingText = Color(0xFF5F5E5A);

class OnboardingSection extends StatelessWidget {
  final int stepNumber;
  final int totalSteps;
  final String title;
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onHeaderTap;
  final Widget child;

  const OnboardingSection({
    super.key,
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    required this.isExpanded,
    required this.isCompleted,
    required this.onHeaderTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8F0), width: 0.6),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onHeaderTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                _StepBadge(
                  stepNumber: stepNumber,
                  isCompleted: isCompleted,
                  isActive: isExpanded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isCompleted ? _kGrey : _kDark,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _kDark,
                  size: 20,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: isExpanded
                ? Padding(padding: const EdgeInsets.only(top: 18), child: child)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isActive;
  const _StepBadge(
      {required this.stepNumber,
      required this.isCompleted,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Color bg = isCompleted
        ? _kGreenTint
        : isActive
            ? _kAccentBlue
            : _kPendingTint;
    final Color fg = isCompleted
        ? _kGreen
        : isActive
            ? Colors.white
            : _kPendingText;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(Icons.check_rounded, size: 15, color: fg)
          : Text('$stepNumber',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
