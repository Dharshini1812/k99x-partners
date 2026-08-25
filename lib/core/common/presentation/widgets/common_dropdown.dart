import 'package:dealer/core/theme/colors.dart';
import 'package:flutter/material.dart';

class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({
    required this.value,
    required this.label,
  });
}

class CommonDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  /// Set to false for short, fixed lists (Fuel Type, Transmission, Body
  /// Style, etc.) where a search box just adds noise. Defaults to true for
  /// long lists (Make, Model, State, City) where searching actually helps.
  final bool searchable;

  const CommonDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.value,
    this.errorText,
    this.enabled = true,
    this.searchable = true,
  });

  static const Color _border = Color(0xFFD0D5DD);
  static const Color _disabledBg = Color(0xFFF2F4F7);
  static const Color _labelColor = Color(0xFF344054);
  static const Color _hintColor = Color(0xFF98A2B3);

  @override
  Widget build(BuildContext context) {
    String selectedLabel = "";

    if (value != null) {
      final index = options.indexWhere((e) => e.value == value);
      if (index != -1) {
        selectedLabel = options[index].label;
      }
    }

    final hasError = errorText != null;
    final hasValue = selectedLabel.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled
                ? () async {
                    FocusScope.of(context).unfocus();

                    final result = await showModalBottomSheet<T>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _SearchBottomSheet<T>(
                        title: label,
                        options: options,
                        searchable: searchable,
                        selectedValue: value,
                      ),
                    );

                    if (result != null) {
                      onChanged?.call(result);
                    }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: enabled ? Colors.white : _disabledBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? const Color(0xFFE74C3C) : _border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? selectedLabel : hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            hasValue ? FontWeight.w600 : FontWeight.w400,
                        color: !enabled
                            ? _hintColor
                            : hasValue
                                ? const Color(0xFF101828)
                                : _hintColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: enabled ? AppColors.primary : _hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFFE74C3C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BOTTOM SHEET — drag handle + header with close button, pill-shaped
// search field (only rendered when `searchable` is true), and the selected
// option highlighted with an accent background + checkmark so it's obvious
// what's currently picked when reopening the sheet.
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<DropdownOption<T>> options;
  final bool searchable;
  final T? selectedValue;

  const _SearchBottomSheet({
    required this.title,
    required this.options,
    required this.searchable,
    required this.selectedValue,
  });

  @override
  State<_SearchBottomSheet<T>> createState() => _SearchBottomSheetState<T>();
}

class _SearchBottomSheetState<T> extends State<_SearchBottomSheet<T>> {
  late List<DropdownOption<T>> filtered;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    filtered = widget.options;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      filtered = widget.options
          .where((e) => e.label.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Without this, the keyboard slides in *over* the sheet instead of the
    // sheet moving up to sit above it — so the moment you start typing
    // (e.g. "tamil nadu"), the search field and/or the results list end up
    // hidden behind the keyboard instead of shrinking to fit above it.
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          // Sheet sizes itself to the content (Column below uses
          // mainAxisSize.min) — this is just a ceiling so a long list
          // (Make, Model, City...) still caps out and scrolls instead of
          // pushing the sheet off-screen. Short lists (Fuel Type,
          // Transmission...) end up with a compact sheet instead of always
          // opening at a fixed 75% height with empty space at the bottom.
          //
          // Subtracting keyboardInset keeps this cap sensible once the
          // keyboard is showing too — otherwise "75% of full screen
          // height" plus the keyboard's own height could push the sheet's
          // top edge (and the search field right below it) up past the
          // top of the screen instead of just scrolling the list.
          constraints: BoxConstraints(
            maxHeight:
                (MediaQuery.of(context).size.height * .75 - keyboardInset)
                    .clamp(200.0, MediaQuery.of(context).size.height * .75),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: const Color(0xFF667085),
                      ),
                    ],
                  ),
                ),
                if (widget.searchable)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Search...",
                          hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF98A2B3),
                          ),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon:
                                      const Icon(Icons.clear_rounded, size: 18),
                                  color: const Color(0xFF98A2B3),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                Flexible(
                  child: filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 32,
                                color: Color(0xFFD0D5DD),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF98A2B3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          // Lets you tap a result without first having to
                          // dismiss the keyboard — matches the usual
                          // "type then tap a suggestion" search UX.
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 2),
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final isSelected =
                                item.value == widget.selectedValue;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => Navigator.pop(context, item.value),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppColors.primary
                                                : const Color(0xFF101828),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/core/common/presentation/widgets/inline_segment_selector.dart

