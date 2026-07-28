import 'package:dealer/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;

  const ProgressStepper({
    super.key,
    required this.currentStep,
  });

  final List<String> steps = const [
    "Details",
    "Photos",
    "Videos",
    "Review",
    "Done",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: List.generate(steps.length, (index) {
          final completed = index < currentStep;
          final active = index == currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: completed || active
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: active ? Colors.white : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index != steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: completed
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active ? AppColors.primary : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
