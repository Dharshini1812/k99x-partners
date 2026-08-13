import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/dashboard/presentation/d.page.dart';
import 'package:dealer/features/my_listings/presentation/pages/my_list_page.dart';
import 'package:dealer/features/profile/presentation/pages/profile.dart';
import 'package:dealer/features/upload/presentation/pages/vehicle_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'custom_bottom_nav.dart';

@AutoRoute()
class BottomNavPage extends ConsumerStatefulWidget {
  const BottomNavPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends ConsumerState<BottomNavPage> {
  int currentIndex = 0;

  @override
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final pages = [
      const DashboardPage(),
      const VehicleListingPage(),
      const MyListPage(),
      const Profile(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}
