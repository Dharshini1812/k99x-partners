// lib/features/client/presentation/widgets/loan_approval_sheet.dart

import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/client/dashboard_client/data/model/loan_approve_model.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/provider.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showLoanApprovalSheet(
  BuildContext context, {
  required ClientVehicleModel vehicle,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LoanApprovalSheet(vehicle: vehicle),
  );
}

class _LoanApprovalSheet extends ConsumerStatefulWidget {
  final ClientVehicleModel vehicle;

  const _LoanApprovalSheet({required this.vehicle});

  @override
  ConsumerState<_LoanApprovalSheet> createState() => _LoanApprovalSheetState();
}

class _LoanApprovalSheetState extends ConsumerState<_LoanApprovalSheet> {
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  int? _tenureMonths = 36; // Default to 36 months

  static const _tenureOptions = [12, 24, 36, 48, 60];

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  String get _title {
    final year = widget.vehicle.mfgYear?.toString() ?? '';
    final make = widget.vehicle.makeName ?? '';
    final model = widget.vehicle.modelName ?? '';
    return [year, make, model].where((s) => s.isNotEmpty).join(' ');
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    final interest = double.tryParse(_interestController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid loan amount')),
      );
      return;
    }
    if (interest == null || interest <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid interest rate')),
      );
      return;
    }
    if (_tenureMonths == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a loan tenure')),
      );
      return;
    }

    final response =
        await ref.read(loanApproveNotifierProvider.notifier).approve(
              LoanApproveRequestModel(
                vehicleId: widget.vehicle.id,
                loanAmount: amount,
                interestRate: interest,
                tenureMonths: _tenureMonths!,
              ),
            );

    if (!mounted) return;

    if (response == null || !response.success) {
      final errorMsg = ref.read(loanApproveNotifierProvider).maybeWhen(
            error: (msg) => msg,
            orElse: () => 'Could not approve loan. Please try again.',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message.isNotEmpty
            ? response.message
            : 'Loan approved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanApproveNotifierProvider);
    final isSubmitting = loanState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E7EC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8C56).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.savings_rounded,
                          color: Color(0xFF1E8C56), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Approve Loan Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stock #${widget.vehicle.id} · $_title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9AA0A6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF888888),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFEEF0F2)),

              // ── Form Body ──────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    CommonTextField(
                      label: 'Approved Loan Amount',
                      hint: 'e.g. 300000',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),
                    CommonTextField(
                      label: 'Interest Rate (% P.A.)',
                      hint: 'e.g. 8.5',
                      controller: _interestController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Inline Tenure Selector (No Popup Clutter) ─────
                    const Text(
                      'Loan Tenure',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tenureOptions.map((m) {
                          final isSelected = _tenureMonths == m;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('$m Months'),
                              selected: isSelected,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                              ),
                              backgroundColor: const Color(0xFFF3F4F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              onSelected: (_) =>
                                  setState(() => _tenureMonths = m),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Buttons ───────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_rounded,
                                          size: 17),
                                      SizedBox(width: 8),
                                      Text(
                                        'Submit Approval',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
