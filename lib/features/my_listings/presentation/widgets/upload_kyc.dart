import 'dart:io';

import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/state_model.dart';
import 'package:dealer/core/common/presentation/provider.dart';
import 'package:dealer/core/common/presentation/widgets/common_dropdown.dart';
import 'package:dealer/core/common/presentation/widgets/common_textfield.dart';
import 'package:dealer/features/my_listings/presentation/logic/Kyc_form_logic.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// NOTE: this file depends on the `image_picker` package for the Aadhaar/PAN
// camera + gallery upload. Add it to pubspec.yaml if it isn't already there:
//
//   dependencies:
//     image_picker: ^1.1.2
//
// `dart:io`'s File is used to preview the picked image, which works on
// Android/iOS but not Flutter Web — if this page also needs to run on web,
// swap the preview to `Image.network`/`Image.memory` via `XFile.readAsBytes()`
// instead of `File(file.path)`.

class UploadKycPage extends ConsumerWidget {
  final String vehicleId;

  const UploadKycPage({super.key, required this.vehicleId});

  static const _purple = Color(0xFF8E5CF7);

  // ── Bank picker sheet ────────────────────────────────────────
  // Bottom sheet over alert dialog: this is a multi-select checklist that
  // can run to 7+ items, and _openPicker()-style bottom sheets are already
  // the established pattern for pickers elsewhere in this app (see
  // vehicle_filter.dart) — a dialog here would be a second, inconsistent
  // pattern for the same kind of interaction.
  Future<void> _showBankPickerSheet(
      BuildContext context, KycFormLogic logic) async {
    // Work on a copy so Cancel (dismiss without tapping Done) doesn't
    // mutate the real selection.
    var draft = {...logic.selectedBanks};

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final allSelected = draft.length == KycFormLogic.allBanks.length;

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _purple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              size: 16,
                              color: _purple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Select Banks',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          _BankCheckRow(
                            label: 'All Banks',
                            checked: allSelected,
                            isMaster: true,
                            onTap: () {
                              setSheetState(() {
                                if (allSelected) {
                                  draft.clear();
                                } else {
                                  draft = {...KycFormLogic.allBanks};
                                }
                              });
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          for (final bank in KycFormLogic.allBanks)
                            _BankCheckRow(
                              label: bank,
                              checked: draft.contains(bank),
                              onTap: () {
                                setSheetState(() {
                                  if (draft.contains(bank)) {
                                    draft.remove(bank);
                                  } else {
                                    draft.add(bank);
                                  }
                                });
                              },
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              logic.setSelectedBanks(draft);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              draft.isEmpty
                                  ? 'Done'
                                  : 'Done · ${draft.length} selected',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ── State / City dropdowns — same searchable pattern as the
  // Identification step (identification_specs_step.dart): State list loads
  // from getStateProvider, picking a state loads that state's cities into
  // getCityProvider, City stays disabled until a State is picked.

  Widget _stateDropdown(WidgetRef ref, KycFormLogic logic) {
    final stateData = ref.watch(getStateProvider);

    return stateData.when(
      initial: () => const CircularProgressIndicator(),
      loading: () => const CircularProgressIndicator(),
      error: (msg) => Text(msg),
      data: (data) => CommonDropdown<StateModel>(
        searchable: true,
        label: 'State *',
        hint: 'Select State',
        value: logic.selectedState,
        options: data
            .map((s) => DropdownOption(value: s, label: s.stateName ?? ''))
            .toList(),
        onChanged: (v) {
          logic.setSelectedState(v);
          ref.read(getCityProvider.notifier).getCity(id: v?.stateId.toString());
        },
      ),
    );
  }

  Widget _cityDropdown(WidgetRef ref, KycFormLogic logic) {
    if (logic.selectedState == null) {
      return const CommonDropdown<CityModel>(
        searchable: true,
        label: 'City *',
        hint: 'Select State First',
        enabled: false,
        options: [],
        onChanged: null,
      );
    }

    final cityData = ref.watch(getCityProvider);

    return cityData.when(
      loading: () => const CircularProgressIndicator(),
      error: (msg) => Text(msg),
      initial: () => const SizedBox(),
      data: (data) => CommonDropdown<CityModel>(
        searchable: true,
        label: 'City *',
        hint: 'Select City',
        value: logic.selectedCity,
        options: data
            .map((e) => DropdownOption(value: e, label: e.cityName ?? ''))
            .toList(),
        onChanged: logic.setSelectedCity,
      ),
    );
  }

  // ── Document upload — real camera/gallery picker ──────────────────

  /// Shows a small action sheet ("Take Photo" / "Choose from Gallery"), then
  /// asks the logic to launch the picked source.
  Future<void> _pickDocumentImage(
    BuildContext context,
    KycFormLogic logic,
    String documentLabel,
    void Function(XFile?) onPicked,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  'Upload $documentLabel',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.photo_camera_rounded, color: _purple),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.photo_library_rounded, color: _purple),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final file = await logic.pickImage(source);
    if (file != null) {
      onPicked(file);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $documentLabel')),
      );
    }
  }

  Future<void> _submit(BuildContext context, KycFormLogic logic) async {
    final success = await logic.submitKyc();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(logic.submitError ?? 'KYC submission failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.watch(kycFormLogic(vehicleId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upload KYC',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              'Vehicle ID: $vehicleId',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9AA0A6),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete the applicant details below to submit KYC for your pre-approved loan offer.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // ── Bank picker trigger — opens the bottom sheet above ──
              InkWell(
                onTap: () => _showBankPickerSheet(context, logic),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _purple.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          size: 15, color: _purple),
                      const SizedBox(width: 6),
                      Text(
                        logic.bankTriggerLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _purple,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: _purple),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Applicant Info ───────────────────────────────────
              _SectionCard(
                title: 'Applicant Info',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CommonTextField(
                          label: 'First Name *',
                          hint: 'John',
                          controller: logic.firstNameController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CommonTextField(
                          label: 'Middle Initial',
                          hint: 'optional',
                          controller: logic.middleInitialController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CommonTextField(
                          label: 'Last Name *',
                          hint: 'Smith',
                          controller: logic.lastNameController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CommonDropdown<String>(
                          label: 'Suffix',
                          hint: ' ',
                          searchable: false,
                          value: logic.suffix,
                          options: const [
                            DropdownOption(value: 'Mr.', label: 'Mr.'),
                            DropdownOption(value: 'Mrs.', label: 'Mrs.'),
                            DropdownOption(value: 'Ms', label: 'Ms'),
                          ],
                          onChanged: logic.setSuffix,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    label: 'Current Address *',
                    hint: '123 Reds Way',
                    controller: logic.addressController,
                  ),
                  const SizedBox(height: 12),
                  _stateDropdown(ref, logic),
                  const SizedBox(height: 10),
                  _cityDropdown(ref, logic),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: 'Pin Code *',
                          hint: '600001',
                          controller: logic.pinCodeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          errorText: logic.pinCodeError,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CommonTextField(
                          label: 'Mobile Number *',
                          hint: '9876543210',
                          controller: logic.mobileController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    label: 'Email *',
                    hint: 'you@example.com',
                    controller: logic.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── KYC Documents ─────────────────────────────────────
              _SectionCard(
                title: 'KYC Documents',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _UploadTile(
                          icon: Icons.badge_outlined,
                          label: 'Aadhaar Card',
                          file: logic.aadhaarFile,
                          onTap: () => _pickDocumentImage(
                            context,
                            logic,
                            'Aadhaar Card',
                            logic.setAadhaarFile,
                          ),
                          onRemove: () => logic.setAadhaarFile(null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _UploadTile(
                          icon: Icons.credit_card_rounded,
                          label: 'PAN Card',
                          file: logic.panFile,
                          onTap: () => _pickDocumentImage(
                            context,
                            logic,
                            'PAN Card',
                            logic.setPanFile,
                          ),
                          onRemove: () => logic.setPanFile(null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Accepted formats: JPG, JPEG, PNG (Max 10 MB each) — captured or picked from gallery',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AA0A6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: logic.isSubmitting
                          ? null
                          : () => _submit(context, logic),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: logic.isSubmitting
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
                                Icon(Icons.check_circle_rounded, size: 17),
                                SizedBox(width: 8),
                                Text(
                                  'Submit KYC',
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANK CHECK ROW — used inside the bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BankCheckRow extends StatelessWidget {
  final String label;
  final bool checked;
  final bool isMaster;
  final VoidCallback onTap;

  const _BankCheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
    this.isMaster = false,
  });

  static const _purple = Color(0xFF8E5CF7);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? _purple : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: checked ? _purple : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isMaster ? FontWeight.w700 : FontWeight.w500,
                color: isMaster ? _purple : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION CARD — local version matching the app's card language
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPLOAD TILE — dashed-border document upload box. Shows a real thumbnail
// once a file's been picked (camera or gallery), with a small × to remove
// it and re-pick.
// ─────────────────────────────────────────────────────────────────────────────

class _UploadTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final XFile? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _UploadTile({
    required this.icon,
    required this.label,
    required this.file,
    required this.onTap,
    required this.onRemove,
  });

  static const _purple = Color(0xFF8E5CF7);
  static const _green = Color(0xFF27AE60);

  bool get _uploaded => file != null;

  @override
  Widget build(BuildContext context) {
    final color = _uploaded ? _green : _purple;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DottedBorderBox(
        color: color.withOpacity(0.4),
        radius: 12,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: _uploaded ? 12 : 22,
            horizontal: _uploaded ? 10 : 0,
          ),
          child: _uploaded
              ? Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file!.path),
                            height: 74,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -7,
                          right: -7,
                          child: InkWell(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Uploaded · tap to change',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: _green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(icon, size: 30, color: color),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Camera or Gallery',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA0A6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Minimal dashed-border container — no external package dependency.
/// If you already use the `dotted_border` package elsewhere, swap this
/// for that instead; this is a plain CustomPaint stand-in.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;

  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
