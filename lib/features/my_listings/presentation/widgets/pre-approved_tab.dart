import 'package:dealer/core/common/data/model/car_make.dart';
import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/presentation/widgets/upload_kyc.dart';
import 'package:flutter/material.dart';

class PreApprovedTabContent extends StatelessWidget {
  final VehicleData vehicle;

  const PreApprovedTabContent({
    super.key,
    required this.vehicle,
  });

  static const _purple = Color(0xFF8E5CF7);

  void _openUploadKyc(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadKycPage(vehicleId: vehicle.id ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFECE7FB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: icon + title + KYC badge ─────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFECE7FB)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      size: 16,
                      color: _purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pre-Approved Offers',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (vehicle.kycExists == false)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openUploadKyc(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload, size: 13, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Upload KYC',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Offer rows ────────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (_, i) {
                return _BankOfferRow(
                  offer: vehicle.allLoanOffers?[i],
                  isLast: i == (vehicle.allLoanOffers!.length - 1),
                  onDetailsTap: () => showPreApprovedOfferDialog(
                    context: context,
                    vehicle:
                        vehicle, // pass this down from PreApprovedTabContent
                    offer: vehicle.allLoanOffers?[i],
                  ),
                );
              },
              separatorBuilder: (_, i) => const SizedBox(height: 6),
              itemCount: vehicle.allLoanOffers?.length ?? 0,
            )
          ],
        ),
      ),
    );
  }
}

class _BankOfferRow extends StatelessWidget {
  final AllLoanOffers? offer;
  final bool isLast;
  final VoidCallback onDetailsTap;

  const _BankOfferRow({
    required this.offer,
    required this.isLast,
    required this.onDetailsTap,
  });

  static const _green = Color(0xFF27AE60);
  static const _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF3F0FB)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer?.lenderName ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '₹${offer?.loanAmount?.toInt()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 12, color: _green),
                    const SizedBox(width: 3),
                    Text(
                      'Approved',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _green.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onDetailsTap,
                borderRadius: BorderRadius.circular(6),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 13, color: _blue),
                    SizedBox(width: 3),
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTHERS TAB — same card language: header + info rows
// ─────────────────────────────────────────────────────────────────────────────

class OthersTabContent extends StatelessWidget {
  final VehicleData vehicle;
  const OthersTabContent({super.key, required this.vehicle});

  static const _green = Color(0xFF27AE60);

  List<OtherDetail> get _details => [
        OtherDetail(
          icon: Icons.event_available_rounded,
          label: 'Dealer Name',
          value: vehicle.dealerFirstName ?? '',
        ),
        const OtherDetail(
          icon: Icons.confirmation_number_rounded,
          label: 'Stock ID',
          value: 'K99X0123',
        ),
        OtherDetail(
          icon: Icons.badge_rounded,
          label: 'Registration',
          value: vehicle.regNo ?? '',
        ),
        OtherDetail(
          icon: Icons.location_on_rounded,
          label: 'Location',
          value: '${vehicle.stateName}-${vehicle.cityName}',
        ),
        OtherDetail(
          icon: Icons.directions_car_filled_rounded,
          label: 'Type',
          value: vehicle.fuelType ?? '',
        ),
        OtherDetail(
          icon: Icons.wifi_tethering_rounded,
          label: 'Status',
          value: vehicle.status ?? '',
          valueColor: _green,
        ),
        OtherDetail(
          icon: Icons.event_available_rounded,
          label: 'Listed On',
          value: vehicle.status == 'LIVE'
              ? vehicle.approvedDate ?? formatDate(vehicle.createdAt)
              : formatDate(vehicle.createdAt),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEFF6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _details.length; i++)
              _OtherDetailRow(
                detail: _details[i],
                isLast: i == _details.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _OtherDetailRow extends StatelessWidget {
  final OtherDetail detail;
  final bool isLast;

  const _OtherDetailRow({required this.detail, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF3F6FA)),
        ),
      ),
      child: Row(
        children: [
          Icon(detail.icon, size: 15, color: const Color(0xFF9AA0A6)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              detail.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            detail.value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: detail.valueColor ?? const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

void showPreApprovedOfferDialog({
  required BuildContext context,
  required VehicleData vehicle,
  required AllLoanOffers? offer,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: _PreApprovedOfferPopup(vehicle: vehicle, offer: offer),
    ),
  );
}

class _PreApprovedOfferPopup extends StatelessWidget {
  final VehicleData vehicle;
  final AllLoanOffers? offer;

  const _PreApprovedOfferPopup({required this.vehicle, required this.offer});

  static const _greenStart = Color(0xFF3EBD93);
  static const _greenEnd = Color(0xFF2C8C7A);
  static const _greenText = Color(0xFF1F8A63);

  @override
  Widget build(BuildContext context) {
    // Adjust these field names to match your actual model
    final lenderName = offer?.lenderName ?? '';
    final loanAmount = offer?.loanAmount?.toInt();
    final interestRate = offer?.interestRate; // e.g. 10.0
    final tenureMonths = offer?.tenureMonths; // e.g. 36

    final vehicleTitle = '${vehicle.mfgYear ?? ''}-${vehicle.makeName ?? ''} '
            '${vehicle.modelName ?? ''} ${vehicle.variantName ?? ''}'
        .trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient header ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_greenStart, _greenEnd],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GREAT NEWS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pre-Approved Offers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (vehicleTitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            vehicleTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Offer card ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3FBF7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCFEFE1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lenderName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _OfferStat(
                          label: null,
                          value: loanAmount != null
                              ? '₹${_formatIndian(loanAmount)}'
                              : '—',
                          valueStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _greenText,
                          ),
                        ),
                        const SizedBox(width: 24),
                        _OfferStat(
                          label: null,
                          value: interestRate != null
                              ? '${interestRate}% p.a.'
                              : '—',
                        ),
                        const SizedBox(width: 24),
                        _OfferStat(
                          label: null,
                          value:
                              tenureMonths != null ? '$tenureMonths mo' : '—',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatIndian(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      final posFromEnd = rest.length - i;
      buffer.write(rest[i]);
      if (posFromEnd > 1 && posFromEnd % 2 == 1) buffer.write(',');
    }
    return '$buffer,$last3';
  }
}

class _OfferStat extends StatelessWidget {
  final String? label;
  final String value;
  final TextStyle? valueStyle;

  const _OfferStat({this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: valueStyle ??
          const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
    );
  }
}
