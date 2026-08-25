// lib/features/client/presentation/widgets/client_stock_card.dart

import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/client/dashboard_client/presentation/widgets/client_view_kyc.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:dealer/features/my_listings/presentation/pages/vehicle_card.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ClientStockCard extends StatelessWidget {
  final ClientVehicleModel vehicle;
  final VoidCallback onPreApproval;
  final VoidCallback? onViewReport;
  final VoidCallback? onDigitalInspection;
  final int badgeCount;
  final VoidCallback? onBadgeTap;

  const ClientStockCard({
    super.key,
    required this.vehicle,
    required this.onPreApproval,
    this.onViewReport,
    this.onDigitalInspection,
    this.badgeCount = 0,
    this.onBadgeTap,
  });

  static const _draftBg = Color(0xFF37414F);

  bool get _isDraft => (vehicle.status ?? '').toUpperCase() == 'DRAFT';
  bool get _isApproved => vehicle.clientApproved;

  String get _title {
    final year = vehicle.mfgYear?.toString() ?? '';
    final make = vehicle.makeName ?? '';
    final model = vehicle.modelName ?? '';
    return [year, make, model].where((s) => s.isNotEmpty).join(' ');
  }

  String get _ageLabel {
    if (vehicle.createdAt == null) return '0';
    final created = DateTime.fromMillisecondsSinceEpoch(vehicle.createdAt!);
    final days = DateTime.now().difference(created).inDays;
    return '$days';
  }

  String _formatKm(int? km) {
    if (km == null) return '-';
    final s = km.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0 && posFromRight % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf km';
  }

  String _money(double? v) {
    if (v == null || v == 0) return '₹0';
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      if (i != 0) {
        if (posFromRight == 3 ||
            (posFromRight > 3 && (posFromRight - 3) % 2 == 0)) {
          buf.write(',');
        }
      }
      buf.write(s[i]);
    }
    return '₹$buf';
  }

  @override
  Widget build(BuildContext context) {
    final inspection = vehicle.dealerVehicleInspection;
    final videoUrl = inspection?.youtubeVideoUrl?.youtubeUrl ??
        inspection?.exteriorVideoUrl?.url;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: thumbnail + title/reg/badge + age ────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(
                  imageUrl: inspection?.frontVehicleImageUrl?.url,
                  isVideo: videoUrl != null && videoUrl.isNotEmpty,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.85),
                      builder: (_) => VehicleMediaPreviewDialog(
                        title: _title,
                        imageUrl: inspection?.frontVehicleImageUrl?.url,
                        videoUrl: videoUrl,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                              height: 1.25,
                            ),
                          ),
                          if (_isDraft)
                            const _StatusPill(text: 'DRAFT', bg: _draftBg)
                          else
                            const _StatusPill(
                                text: 'LIVE', bg: Color(0xFF27AE60)),
                          if (badgeCount > 0)
                            StockCountBadge(
                              count: badgeCount,
                              onTap: onBadgeTap,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.id,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if ((vehicle.fuelType ?? '').isNotEmpty ||
                              (vehicle.transmission ?? '').isNotEmpty)
                            _MiniChip(
                              text: [
                                vehicle.fuelType,
                                vehicle.transmission,
                              ].where((e) => (e ?? '').isNotEmpty).join(' · '),
                              bg: const Color(0xFFF3F4F6),
                              textColor: const Color(0xFF4B5563),
                            ),
                          _MiniChip(
                            text: _formatKm(vehicle.kmDriven),
                            bg: const Color(0xFFEFF6FF),
                            textColor: const Color(0xFF2563EB),
                          ),
                          if ((vehicle.regNo ?? '').isNotEmpty)
                            _MiniChip(
                              text: vehicle.regNo!,
                              bg: const Color(0xFFF3EEFC),
                              textColor: const Color(0xFF7C3AED),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AgeCalendarBadge(
                      ageInDays: int.tryParse(_ageLabel) ?? 0,
                    ),
                    if (vehicle.kycExists == true) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => showClientKycBottomSheet(
                          context,
                          vehicleId: vehicle.id,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAFBF2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF1E8C56), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 11.5, color: Color(0xFF1E8C56)),
                              SizedBox(width: 3.5),
                              Text(
                                'View KYC',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E8C56),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if ((vehicle.dealerFirstName ?? '').isNotEmpty ||
              (vehicle.cityName ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  if ((vehicle.dealerFirstName ?? '').isNotEmpty) ...[
                    const Icon(Icons.storefront_rounded,
                        size: 13, color: Color(0xFF9AA0A6)),
                    const SizedBox(width: 4),
                    Text(
                      'Seller: ${vehicle.dealerFirstName}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if ((vehicle.dealerFirstName ?? '').isNotEmpty &&
                      (vehicle.cityName ?? '').isNotEmpty)
                    const Text(
                      '  ·  ',
                      style: TextStyle(color: Color(0xFF9AA0A6)),
                    ),
                  if ((vehicle.cityName ?? '').isNotEmpty) ...[
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: Color(0xFF9AA0A6)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        [vehicle.cityName, vehicle.stateName]
                            .where((e) => (e ?? '').isNotEmpty)
                            .join(' · '),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ── Report / Inspection buttons ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                if (onViewReport != null)
                  Expanded(
                    child: _SmallActionButton(
                      icon: Icons.description_outlined,
                      label: 'View Report',
                      filled: true,
                      onTap: onViewReport!,
                    ),
                  ),
                if (onViewReport != null && onDigitalInspection != null)
                  const SizedBox(width: 8),
                if (onDigitalInspection != null)
                  Expanded(
                    child: _SmallActionButton(
                      icon: Icons.laptop_mac_rounded,
                      label: 'Digital Inspection',
                      filled: false,
                      onTap: onDigitalInspection!,
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F1F4)),

          // ── Condition ratings ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: _ConditionChip(
                    label: 'Exterior',
                    value: inspection?.exteriorCondition,
                  ),
                ),
                Expanded(
                  child: _ConditionChip(
                    label: 'Engine',
                    value: inspection?.engineCondition,
                  ),
                ),
                Expanded(
                  child: _ConditionChip(
                    label: 'Interior',
                    value: inspection?.interiorCondition,
                  ),
                ),
                if (inspection?.ownerCount != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Owners',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9AA0A6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${inspection!.ownerCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F1F4)),

          // ── Price intelligence + Pre Approval ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriceRow(
                          label: 'Seller Exp.',
                          value: _money(vehicle.dealerPrice)),
                      const SizedBox(height: 3),
                      vehicle.marketPrice == null || vehicle.marketPrice == 0
                          ? const _PriceRow(
                              label: 'Valuation',
                              valueWidget: _InProgressBadge())
                          : _PriceRow(
                              label: 'Avg Market',
                              value: _money(vehicle.marketPrice)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildActionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (_isApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E8C56), width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 14, color: Color(0xFF1E8C56)),
            SizedBox(width: 4),
            Text(
              'PRE APPROVED',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E8C56),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPreApproval,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E8C56),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.verified_rounded, size: 15),
      label: const Text(
        'Pre Approval',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StockCountBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const StockCountBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF00C48C),
            width: 1.2,
          ),
        ),
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Color(0xFF00A86B),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool isVideo;
  final VoidCallback? onTap;

  const _Thumbnail({
    this.imageUrl,
    required this.isVideo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF1D2748),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car_rounded,
                      color: Colors.white54,
                    ),
                  )
                : const Icon(Icons.directions_car_rounded,
                    color: Colors.white54),
          ),
          if (isVideo)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color bg;

  const _StatusPill({required this.text, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;

  const _MiniChip(
      {required this.text, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: filled ? null : Border.all(color: const Color(0xFFD7E3FF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 13, color: filled ? Colors.white : AppColors.primary),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: filled ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final String? value;

  const _ConditionChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9AA0A6),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF39C12)),
            const SizedBox(width: 2),
            Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _PriceRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        valueWidget ??
            Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFC17A15),
              ),
            ),
      ],
    );
  }
}

class _InProgressBadge extends StatelessWidget {
  const _InProgressBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'In Progress',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG WITH ACTIVE INLINE YOUTUBE VIDEO PLAYER
// ─────────────────────────────────────────────────────────────────────────────

class VehicleMediaPreviewDialog extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final String? videoUrl;

  const VehicleMediaPreviewDialog({
    super.key,
    required this.title,
    this.imageUrl,
    this.videoUrl,
  });

  @override
  State<VehicleMediaPreviewDialog> createState() =>
      _VehicleMediaPreviewDialogState();
}

class _VehicleMediaPreviewDialogState extends State<VehicleMediaPreviewDialog> {
  int _currentIndex = 0;
  late final List<Map<String, dynamic>> _mediaItems;
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  String? _parseVideoId(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final trimmed = input.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }
    return YoutubePlayer.convertUrlToId(trimmed);
  }

  @override
  void initState() {
    super.initState();
    _mediaItems = [];

    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      _mediaItems.add({
        'type': 'image',
        'url': widget.imageUrl!,
        'label': 'Front View',
      });
    }

    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      final videoId = _parseVideoId(widget.videoUrl);

      if (videoId != null && videoId.isNotEmpty) {
        _mediaItems.add({
          'type': 'video',
          'url': widget.videoUrl!,
          'label': 'Exterior Video',
        });

        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            useHybridComposition: true,
            enableCaption: false,
            isLive: false,
          ),
        )..addListener(() {
            if (mounted) setState(() {});
          });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _mediaItems.length - 1) {
      setState(() => _currentIndex++);
      if (_controller != null && _isPlayerReady) {
        _controller!.play();
      }
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _controller?.pause();
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaItems.isEmpty) return const SizedBox.shrink();

    final currentItem = _mediaItems[_currentIndex];
    final isVideo = currentItem['type'] == 'video';

    return Dialog(
      backgroundColor: const Color(0xFF131826),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520, maxWidth: 500),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFF232B40)),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: isVideo
                          ? (_controller != null
                              ? YoutubePlayer(
                                  controller: _controller!,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.blueAccent,
                                  onReady: () {
                                    setState(() {
                                      _isPlayerReady = true;
                                    });
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    'Invalid Video URL',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                ))
                          : Image.network(
                              currentItem['url'],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_rounded,
                                    color: Colors.white54, size: 40),
                              ),
                            ),
                    ),
                  ),
                  if (_currentIndex > 0)
                    Positioned(
                      left: 6,
                      child: _NavCircleButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: _prev,
                      ),
                    ),
                  if (_currentIndex < _mediaItems.length - 1)
                    Positioned(
                      right: 6,
                      child: _NavCircleButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: _next,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${currentItem['label']} • ${_currentIndex + 1} / ${_mediaItems.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
