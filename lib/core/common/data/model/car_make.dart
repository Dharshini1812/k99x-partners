import 'package:flutter/material.dart';

class CarMake {
  final String name;
  final String logo;

  const CarMake({
    required this.name,
    required this.logo,
  });
}

class OtherDetail {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const OtherDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}
