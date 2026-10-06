import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String formatDate(dynamic timestamp) {
  if (timestamp == null) return '-';

  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd/MM/yyyy').format(date);
}

String? toTitleCase(String? input) {
  if (input == null) return null;
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final first = trimmed[0].toUpperCase();
  final rest = trimmed.length > 1 ? trimmed.substring(1).toLowerCase() : '';
  return '$first$rest';
}

String? convertCondition(String? text) {
  switch (text) {
    case '5.0':
      return 'Excellent';
    case '4.0':
      return 'Good';
    case '3.0':
      return 'Average';
    case '2.0':
      return 'Poor';
    case '1.0':
      return 'Bad';
  }
  return '';
}

String getFlutterImageUrl(String url) {
  if (url.isEmpty) return url;

  // Convert Cloudinary AVIF delivery to WebP
  if (url.contains('res.cloudinary.com') && url.contains('/image/upload/')) {
    return url.replaceFirst(
      '/image/upload/',
      '/image/upload/f_webp/',
    );
  }

  return url;
}

/// Groups vehicles by make+model+variant, keeping only the first of each
/// group to render as a card. Returns the deduped list to display, plus
/// a lookup from that representative vehicle's id -> all vehicles in its
/// group (including itself) so the card can compute its own +N and pass
/// the full group to the sheet.
({List<VehicleData> display, Map<String, List<VehicleData>> groups})
    dedupeByVariant(List<VehicleData> items) {
  final Map<String, List<VehicleData>> groups = {};
  final List<VehicleData> display = [];

  for (final v in items) {
    final key = '${v.make}_${v.model}_${v.variant}';
    if (groups.containsKey(key)) {
      groups[key]!.add(v);
    } else {
      groups[key] = [v];
      display.add(v); // first occurrence becomes the representative card
    }
  }

  return (display: display, groups: groups);
}

// Helper class to hold grouped stock info
class GroupedVehicleStock {
  final dynamic primaryVehicle;
  final List<dynamic> matchingVehicles;

  GroupedVehicleStock({
    required this.primaryVehicle,
    required this.matchingVehicles,
  });

  int get count => matchingVehicles.length;
}

List<GroupedVehicleStock> groupVehicles(List<dynamic> vehicles) {
  final Map<String, List<dynamic>> groupedMap = {};

  for (final v in vehicles) {
    // Unique key combination: Make_Model_Variant
    final key = '${v.make}_${v.model}_${v.variant}'.toLowerCase();
    groupedMap.putIfAbsent(key, () => []).add(v);
  }

  return groupedMap.values.map((group) {
    return GroupedVehicleStock(
      primaryVehicle: group.first,
      matchingVehicles: group,
    );
  }).toList();
}

// Helper method to navigate directly back to the Dashboard tab
void navigateToDashboard(WidgetRef ref, BuildContext context) {
  // 1. Reset upload form steps back to step 0
  ref.read(listingStepProvider.notifier).state = 0;

  // 2. Clear current listing data state
  ref.read(listingProvider.notifier).state = const VehicleListingModel();

  // 3. Switch bottom navigation index back to Dashboard (Index 0)
  ref.read(bottomNavIndexProvider.notifier).state = 0;

  // 4. Pop any active modal sheets, review sub-pages, or dialogs if open
  Navigator.of(context).popUntil((route) => route.isFirst);
}

const Map<String, String> stateCodes = {
  'andhra pradesh': 'AP',
  'arunachal pradesh': 'AR',
  'assam': 'AS',
  'bihar': 'BR',
  'chhattisgarh': 'CG',
  'goa': 'GA',
  'gujarat': 'GJ',
  'haryana': 'HR',
  'himachal pradesh': 'HP',
  'jharkhand': 'JH',
  'karnataka': 'KA',
  'kerala': 'KL',
  'madhya pradesh': 'MP',
  'maharashtra': 'MH',
  'manipur': 'MN',
  'meghalaya': 'ML',
  'mizoram': 'MZ',
  'nagaland': 'NL',
  'odisha': 'OD',
  'orissa': 'OD',
  'punjab': 'PB',
  'rajasthan': 'RJ',
  'sikkim': 'SK',
  'tamil nadu': 'TN',
  'tamilnadu': 'TN',
  'telangana': 'TS',
  'tripura': 'TR',
  'uttar pradesh': 'UP',
  'uttarakhand': 'UK',
  'west bengal': 'WB',
  'andaman and nicobar islands': 'AN',
  'chandigarh': 'CH',
  'dadra and nagar haveli and daman and diu': 'DD',
  'delhi': 'DL',
  'jammu and kashmir': 'JK',
  'ladakh': 'LA',
  'lakshadweep': 'LD',
  'puducherry': 'PY',
  'pondicherry': 'PY',
};

String shortState(String? state) {
  if (state == null || state.trim().isEmpty) return '';
  final key = state.trim().toLowerCase();
  return stateCodes[key] ?? state.trim(); // fallback to original name
}

// "HDFC BANK ltd" -> "Hdfc Bank Ltd"
String titleCase(String? input) {
  if (input == null || input.trim().isEmpty) return '';
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

// "3.0" -> 3.0, null/invalid -> null
double? parseRating(String? value) {
  if (value == null) return null;
  final r = double.tryParse(value.trim());
  if (r == null) return null;
  return r.clamp(0, 5).toDouble();
}
