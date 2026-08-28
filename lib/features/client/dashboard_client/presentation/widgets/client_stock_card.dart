// lib/features/client/dashboard_client/presentation/widgets/client_stock_card.dart

import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:dealer/features/client/dashboard_client/presentation/widgets/client_view_kyc.dart';
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

  bool get _isApproved => vehicle.clientApproved;

  String _toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String get _title {
    final year = vehicle.mfgYear?.toString() ?? '';
    final make = _toTitleCase(vehicle.makeName ?? '');
    final model = (vehicle.modelName ?? '').toUpperCase();
    final variant = (vehicle.variantName ?? '').toUpperCase();

    return [year, make, model, variant].where((s) => s.isNotEmpty).join(' ');
  }

  String get _ageLabel {
    if (vehicle.createdAt == null) return '0';
    final created = DateTime.fromMillisecondsSinceEpoch(vehicle.createdAt!);
    return '${DateTime.now().difference(created).inDays}';
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

  void _handleMediaTap(
      BuildContext context, String? imageUrl, String? videoUrl) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final hasVideo = videoUrl != null && videoUrl.trim().isNotEmpty;

    if (!hasImage && !hasVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No media preview available for this vehicle'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => VehicleMediaPreviewDialog(
        title: _title,
        imageUrl: hasImage ? imageUrl : null,
        videoUrl: hasVideo ? videoUrl : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inspection = vehicle.dealerVehicleInspection;
    final imageUrl = inspection?.frontVehicleImageUrl?.url;
    final videoUrl = inspection?.youtubeVideoUrl?.youtubeUrl ??
        inspection?.exteriorVideoUrl?.url;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Image Banner with Overlaid Badges & Age Calendar ──────────
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 2.2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _handleMediaTap(context, imageUrl, videoUrl),
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.directions_car_filled_rounded,
                              color: Colors.white38,
                              size: 48,
                            ),
                          )
                        else
                          const Icon(
                            Icons.directions_car_filled_rounded,
                            color: Colors.white38,
                            size: 48,
                          ),
                        if (videoUrl != null && videoUrl.isNotEmpty)
                          Center(
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white30, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Floating Left: Similar Stocks Badge ──
              if (badgeCount > 0)
                Positioned(
                  top: 10,
                  left: 10,
                  child: InkWell(
                    onTap: onBadgeTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00C48C), width: 1),
                      ),
                      child: Text(
                        '+$badgeCount',
                        style: const TextStyle(
                          color: Color(0xFF00E699),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Floating Right: Calendar Badge ──
              Positioned(
                top: 8,
                right: 10,
                child: AgeCalendarBadge(
                  ageInDays: int.tryParse(_ageLabel) ?? 0,
                ),
              ),
            ],
          ),

          // ── Main Card Content ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & KYC Verified Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            vehicle.id,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (vehicle.kycExists == true)
                      InkWell(
                        onTap: () => showClientKycBottomSheet(
                          context,
                          vehicleId: vehicle.id,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF16A34A), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 12, color: Color(0xFF16A34A)),
                              SizedBox(width: 4),
                              Text(
                                'View KYC',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Spec Badges Bar ──
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if ((vehicle.fuelType ?? '').isNotEmpty ||
                        (vehicle.transmission ?? '').isNotEmpty)
                      _InfoChip(
                        icon: Icons.local_gas_station_rounded,
                        text: [
                          vehicle.fuelType,
                          vehicle.transmission,
                        ].where((e) => (e ?? '').isNotEmpty).join(' · '),
                      ),
                    _InfoChip(
                      icon: Icons.speed_rounded,
                      text: _formatKm(vehicle.kmDriven),
                    ),
                    if ((vehicle.regNo ?? '').isNotEmpty)
                      _InfoChip(
                        icon: Icons.pin_outlined,
                        text: vehicle.regNo!,
                        highlight: true,
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Dealer & Location ──
                Row(
                  children: [
                    if ((vehicle.dealerFirstName ?? '').isNotEmpty) ...[
                      const Icon(Icons.storefront_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.dealerFirstName!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(' · ',
                          style: TextStyle(color: Color(0xFFCBD5E1))),
                    ],
                    if ((vehicle.cityName ?? '').isNotEmpty) ...[
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          [vehicle.cityName, vehicle.stateName]
                              .where((e) => (e ?? '').isNotEmpty)
                              .join(', '),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // ── Actions: View Report Button & Digital Inspection Badge ──
                Row(
                  children: [
                    if (onViewReport != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onViewReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          icon:
                              const Icon(Icons.description_outlined, size: 14),
                          label: const Text(
                            'View Report',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    if (onViewReport != null) const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.laptop_mac_rounded,
                                size: 13, color: Color(0xFF64748B)),
                            SizedBox(width: 5),
                            Text(
                              'Digital Inspection',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // ── Inspection Ratings ──
                Row(
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
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${inspection!.ownerCount}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // ── Price Intelligence & Pre-Approval Action ──
                Row(
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
                          _PriceRow(
                            label: 'Valuation',
                            value: vehicle.marketPrice != null &&
                                    vehicle.marketPrice! > 0
                                ? _money(vehicle.marketPrice)
                                : null,
                            valueWidget: vehicle.marketPrice == null ||
                                    vehicle.marketPrice == 0
                                ? const _InProgressBadge()
                                : null,
                          ),
                          const SizedBox(height: 3),
                          _PriceRow(
                              label: 'Avg Market',
                              value: _money(vehicle.marketPrice)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (_isApproved) {
      final loanAmt = vehicle.loanAmount;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF22C55E), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 13, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text(
                  'PRE APPROVED',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16A34A),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            if (loanAmt != null && loanAmt > 0) ...[
              const SizedBox(height: 3),
              Text(
                _money(loanAmt),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPreApproval,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFF7ED),
        foregroundColor: const Color(0xFFC2410C),
        side: const BorderSide(color: Color(0xFFFDBA74), width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.hourglass_top_rounded,
          size: 13, color: Color(0xFFC2410C)),
      label: const Text(
        'Pre Approval Pending',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFFC2410C),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF5F3FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color:
                highlight ? const Color(0xFFDDD6FE) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: highlight
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color:
                  highlight ? const Color(0xFF7C3AED) : const Color(0xFF334155),
            ),
          ),
        ],
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
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
            const SizedBox(width: 2),
            Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
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
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        valueWidget ??
            Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD97706),
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
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'In Progress',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG WITH INLINE YOUTUBE VIDEO PLAYER
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
      backgroundColor: const Color(0xFF0F172A),
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
                      color: Color(0xFF38BDF8),
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
            const Divider(height: 1, color: Color(0xFF1E293B)),
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
