// lib/features/my_listings/presentation/logic/my_list/my_stock_notifier.dart

import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/domain/usecase/my_stock.dart';
import 'package:dealer/features/my_listings/presentation/logic/my_list/my_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyStockNotifier extends StateNotifier<MyListState> {
  final MyListUsecase _getMyStockUsecase;
  List<VehicleData> _originalList = [];

  MyStockNotifier({
    required MyListUsecase getMyStockUsecase,
    MyListState? initialState,
  })  : _getMyStockUsecase = getMyStockUsecase,
        super(initialState ?? const MyListState.initial());

  void applyFilter(LiveStockFilter filter) {
    List<VehicleData> filtered = List.from(_originalList);

    /// 1. Query Search (RegNo, Make, Model, Variant)
    if (filter.query != null && filter.query!.trim().isNotEmpty) {
      final search = filter.query!.toLowerCase().trim();

      filtered = filtered.where((vehicle) {
        return (vehicle.regNo ?? "").toLowerCase().contains(search) ||
            (vehicle.makeName ?? "").toLowerCase().contains(search) ||
            (vehicle.modelName ?? "").toLowerCase().contains(search) ||
            (vehicle.variantName ?? "").toLowerCase().contains(search);
      }).toList();
    }

    /// 2. Make
    if (filter.make != null && filter.make!.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        return (vehicle.makeName ?? "")
            .toLowerCase()
            .contains(filter.make!.toLowerCase());
      }).toList();
    }

    /// 3. Model
    if (filter.model != null && filter.model!.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        return (vehicle.modelName ?? "")
            .toLowerCase()
            .contains(filter.model!.toLowerCase());
      }).toList();
    }

    /// 4. Manufacturing Year
    if (filter.year != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.mfgYear == filter.year;
      }).toList();
    }

    /// 5. Owner Count
    if (filter.owner != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.dealerVehicleInspection?.ownerCount == filter.owner;
      }).toList();
    }

    /// 6. KM Range
    if (filter.minKm != null || filter.maxKm != null) {
      filtered = filtered.where((vehicle) {
        final km = vehicle.kmDriven ?? 0;
        return km >= (filter.minKm ?? 0) && km <= (filter.maxKm ?? 999999);
      }).toList();
    }

    state = MyListState.data(
      VehicleResponse(
        data: filtered,
        success: true,
        message: '',
      ),
    );
  }

  void clearFilter() {
    state = MyListState.data(
      VehicleResponse(
        data: List.from(_originalList),
        success: true,
        message: '',
      ),
    );
  }

  Future<void> getMyStock({int? offset, int? limit}) async {
    state = const MyListState.loading();

    try {
      final result =
          await _getMyStockUsecase.getMyListings(offset: offset, limit: limit);

      result.fold(
        (failure) {
          state = MyListState.error(failure.msg ?? '');
        },
        (response) {
          _originalList = response.data;
          state = MyListState.data(response);
        },
      );
    } catch (e) {
      state = MyListState.error(e.toString());
    }
  }
}
