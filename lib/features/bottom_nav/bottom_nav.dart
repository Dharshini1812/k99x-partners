import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/dashboard/presentation/d.page.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/live_auction/presentation/pages/auction_homepage.dart';
import 'package:dealer/features/my_listings/presentation/pages/my_list_page.dart';
import 'package:dealer/features/profile/presentation/pages/profile.dart';
import 'package:dealer/features/trial/presentation/logic/trial_logic.dart';
import 'package:dealer/features/trial/presentation/widgets/trial_blocked_dialog.dart';
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
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final trial = ref.watch(trialLogic);
    final user = ref.watch(dLogic).user;

    // Trial mode is active if there is no logged-in user and trial is active
    final bool isTrialMode = (user == null) && trial.isTrialSession;

    // If in free trial, lock tabs 1, 2, 3, 4. If logged in, unlock everything.
    final lockedIndices = isTrialMode ? {1, 2, 3, 4} : <int>{};

    final pages = [
      const AuctionHomePage(),
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
          lockedIndices: lockedIndices,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          onLockedTap: (index) {
            showTrialBlockedDialog(
              context,
              ref,
              expired: trial.isTrialExpired,
              featureTitle: 'This needs a registered account',
              featureMessage:
                  'You\'re exploring the app on a free trial. Sign up as a dealer to unlock Home, Sell, Listings and your Profile.',
            );
          },
        ),
      ),
    );
  }
}
