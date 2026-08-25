// lib/features/client/dashboard_client/presentation/widgets/client_view_kyc.dart

import 'package:dealer/features/client/dashboard_client/data/model/kyc_view_model.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showClientKycBottomSheet(
  BuildContext context, {
  required String vehicleId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _KycViewSheetLoader(vehicleId: vehicleId),
  );
}

class _KycViewSheetLoader extends ConsumerStatefulWidget {
  final String vehicleId;
  const _KycViewSheetLoader({required this.vehicleId});

  @override
  ConsumerState<_KycViewSheetLoader> createState() =>
      _KycViewSheetLoaderState();
}

class _KycViewSheetLoaderState extends ConsumerState<_KycViewSheetLoader> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(clientKycViewNotifierProvider.notifier)
          .fetch(widget.vehicleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(clientKycViewNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dealer KYC Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: kycState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (msg) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        msg,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                  data: (kyc) {
                    if (kyc == null) {
                      return const Center(child: Text('No KYC record found'));
                    }
                    return _KycContentList(
                      kyc: kyc.data,
                      controller: scrollController,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KycContentList extends StatelessWidget {
  final ClientKycModel? kyc;
  final ScrollController controller;

  const _KycContentList({required this.kyc, required this.controller});

  void _openImagePreview(BuildContext context, String url) {
    if (url.trim().isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_rounded,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Unable to load document image'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = [
      kyc?.firstName,
      kyc?.middleInitial,
      kyc?.lastName,
      kyc?.suffix
    ].where((e) => (e ?? '').trim().isNotEmpty).join(' ');

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        // ── 1. Applicant Identity ──────────────────────────────────
        _SectionCard(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF2563EB),
          title: 'Applicant Identity',
          children: [
            _InfoRow(
                label: 'FULL NAME',
                value: fullName.isNotEmpty ? fullName : '-'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    label: 'MOBILE NUMBER',
                    value: kyc?.mobileNo ?? '-',
                    icon: Icons.phone_android_rounded,
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    label: 'EMAIL ADDRESS',
                    value: kyc?.email ?? '-',
                    icon: Icons.email_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── 2. Registered Address ──────────────────────────────────
        _SectionCard(
          icon: Icons.home_work_outlined,
          iconColor: const Color(0xFFD97706),
          title: 'Registered Address',
          children: [
            _InfoRow(label: 'STREET ADDRESS', value: kyc?.address ?? '-'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _InfoRow(label: 'CITY', value: kyc?.city ?? '-')),
                Expanded(
                    child: _InfoRow(label: 'STATE', value: kyc?.state ?? '-')),
                Expanded(
                    child:
                        _InfoRow(label: 'PINCODE', value: kyc?.pincode ?? '-')),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── 3. Primary KYC Documents ──────────────────────────────
        _SectionCard(
          icon: Icons.badge_outlined,
          iconColor: const Color(0xFF7C3AED),
          title: 'Primary KYC Documents',
          children: [
            Row(
              children: [
                if (kyc?.aadhaarCard?.url != null)
                  Expanded(
                    child: _DocPreviewTile(
                      label: 'AADHAAR CARD',
                      imageUrl: kyc?.aadhaarCard!.url ?? '',
                      onTap: () => _openImagePreview(
                          context, kyc?.aadhaarCard!.url ?? ''),
                    ),
                  ),
                if (kyc?.aadhaarCard?.url != null && kyc?.pancard?.url != null)
                  const SizedBox(width: 12),
                if (kyc?.pancard?.url != null)
                  Expanded(
                    child: _DocPreviewTile(
                      label: 'PAN CARD',
                      imageUrl: kyc?.pancard!.url ?? '',
                      onTap: () =>
                          _openImagePreview(context, kyc?.pancard!.url ?? ''),
                    ),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── 4. Additional Supporting Documents ─────────────────────
        _SectionCard(
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF059669),
          title: 'Additional Supporting Documents',
          children: [
            if (kyc?.documentUrls.isEmpty ?? true)
              const Text(
                'No supporting documents uploaded',
                style: TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kyc!.documentUrls.map((url) {
                  return InkWell(
                    onTap: () => _openImagePreview(context, url),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF3F4F6)),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _InfoRow({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9AA0A6),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: const Color(0xFF6B7280)),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocPreviewTile extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback onTap;

  const _DocPreviewTile({
    required this.label,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9AA0A6),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Color(0xFF9AA0A6),
                      size: 28,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
