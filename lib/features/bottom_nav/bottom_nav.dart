import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/my_listings/data/model/car_model.dart';
import 'package:dealer/features/my_listings/presentation/pages/my_list_page.dart';
import 'package:dealer/features/my_listings/presentation/pages/vehicle_card.dart';
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

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Container(),
      const VehicleListingPage(),
      MyListPage(),
      Container(),
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
            changeTab(index);
          },
        ),
      ),
    );
  }
}
