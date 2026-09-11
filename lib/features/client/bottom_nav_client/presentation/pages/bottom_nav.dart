import 'package:auto_route/auto_route.dart';
import 'package:dealer/features/bottom_nav/provider.dart';
import 'package:dealer/features/client/bottom_nav_client/presentation/pages/custom_bottom.dart';
import 'package:dealer/features/client/dashboard_client/presentation/pages/client_dash_page.dart';
import 'package:dealer/features/client/dashboard_client/presentation/pages/client_stocks_page.dart';
import 'package:dealer/features/client/profile/presentation/pages/profile_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@AutoRoute()
class ClientBottomNavPage extends ConsumerStatefulWidget {
  const ClientBottomNavPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClientBottomNavPageState();
}

class _ClientBottomNavPageState extends ConsumerState<ClientBottomNavPage> {
  int currentIndex = 0;

  @override
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final pages = [
      const ClientDashboardPage(),
      const ClientStocksPage(),
      const ClientProfile()
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: ClientBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}
