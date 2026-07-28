// lib/core/widgets/common_dropdown.dart
import 'package:flutter/material.dart';

class DropdownOption<T> {
  final T value;
  final String label;
  const DropdownOption({required this.value, required this.label});
}

class CommonDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  const CommonDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final validValue = options.any((o) => o.value == value) ? value : null;

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
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: validValue,
          isExpanded: true,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          items: options
              .map(
                (o) => DropdownMenuItem<T>(
                  value: o.value,
                  child: Text(o.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            errorText: errorText,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF2F4F7),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFFD0D5DD),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.blue,
                width: 1.4,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
