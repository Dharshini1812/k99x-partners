import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final listingsMainTabProvider = StateProvider<int>((ref) => 0);

/// Controls the active sub-tab index inside MyStockTab (0: My LiveStock, 1: Pre-Approved, 2: Pending Stock)
final myStockSubTabProvider = StateProvider<int>((ref) => 0);
