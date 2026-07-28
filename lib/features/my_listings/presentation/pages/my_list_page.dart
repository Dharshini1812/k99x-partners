import 'package:dealer/features/my_listings/presentation/logic/my_list_logic.dart';
import 'package:dealer/features/my_listings/presentation/pages/vehicle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  ConsumerState<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Listings",
            style: TextStyle(fontSize: 12),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Live Stock"),
                    Tab(text: "My Stock"),
                    Tab(text: "Wanted Stock"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [SellVehicleTab(), WantedVehicleTab(), Container()],
        ),
      ),
    );
  }
}

class SellVehicleTab extends ConsumerStatefulWidget {
  const SellVehicleTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SellVehicleTabState();
}

class _SellVehicleTabState extends ConsumerState<SellVehicleTab> {
  @override
  Widget build(BuildContext context) {
    final logic = ref.read(myListLogic);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (_, index) {
        return CarInspectionCard();
      },
    );
  }
}

class WantedVehicleTab extends StatelessWidget {
  const WantedVehicleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return Card(
          child: ListTile(
            title: Text("Wanted Vehicle ${index + 1}"),
            subtitle: const Text("Vehicle details"),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
