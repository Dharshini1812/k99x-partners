// ─────────────────────────────────────────────────────────────────────────────
// RECENT ARRIVALS — real vehicle photos with age-in-stock (days), tap to enlarge
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class _VehicleArrival {
  final String imageUrl;
  final int ageInDays;
  final String regNo;

  const _VehicleArrival({
    required this.imageUrl,
    required this.ageInDays,
    required this.regNo,
  });
}

class RecentArrivalsCard extends StatelessWidget {
  // Demo data — replace with your Vehicle list (image, inward date -> days, reg no).
  static const _arrivals = [
    _VehicleArrival(
        imageUrl: 'images/car1.webp', ageInDays: 3, regNo: 'TN 09 AB 1234'),
    _VehicleArrival(
        imageUrl: 'images/car1.webp', ageInDays: 12, regNo: 'TN 22 CD 5678'),
    _VehicleArrival(
        imageUrl: 'images/car1.webp', ageInDays: 27, regNo: 'TN 10 EF 9012'),
    _VehicleArrival(
        imageUrl: 'images/car1.webp', ageInDays: 45, regNo: 'TN 07 GH 3456'),
    _VehicleArrival(
        imageUrl: 'images/car1.webp', ageInDays: 61, regNo: 'TN 14 IJ 7890'),
  ];

  const RecentArrivalsCard({super.key});

  void _openEnlarged(BuildContext context, _VehicleArrival v) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) => _EnlargedVehicleView(vehicle: v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F1F4)),
      ),
      child: SizedBox(
        height: 112,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _arrivals.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final v = _arrivals[i];
            return GestureDetector(
              onTap: () => _openEnlarged(context, v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      v.imageUrl,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        debugPrint(__.toString());
                        return Container(
                          width: 84,
                          height: 84,
                          color: const Color(0xFFF0F1F4),
                          child: const Icon(Icons.directions_car_rounded,
                              color: Color(0xFF9AA0A6)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${v.ageInDays}d',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B4EFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENLARGED VIEW — tapped vehicle photo, full size, with reg no. overlay
// ─────────────────────────────────────────────────────────────────────────────

class _EnlargedVehicleView extends StatelessWidget {
  final _VehicleArrival vehicle;
  const _EnlargedVehicleView({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              vehicle.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 260,
                color: const Color(0xFF1D2748),
                child: const Icon(Icons.directions_car_rounded,
                    size: 60, color: Colors.white54),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                vehicle.regNo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
