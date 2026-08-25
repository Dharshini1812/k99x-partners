import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
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
