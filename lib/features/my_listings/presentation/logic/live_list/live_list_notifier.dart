import 'package:dealer/features/my_listings/data/model/filter_model.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/my_listings/domain/usecase/live_stock.dart';
import 'package:dealer/features/my_listings/presentation/logic/live_list/live_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveStockNotifier extends StateNotifier<LiveListState> {
  final LiveListUsecase _getLiveStockUsecase;
  List<VehicleData> _originalList = [];
  LiveStockNotifier({
    required LiveListUsecase getLiveStockUsecase,
    LiveListState? initialState,
  })  : _getLiveStockUsecase = getLiveStockUsecase,
        super(initialState ?? const LiveListState.initial());

  void applyFilter(LiveStockFilter filter) {
    List<VehicleData> filtered = List.from(_originalList);

    /// Search
    if (filter.query != null && filter.query!.trim().isNotEmpty) {
      final search = filter.query!.toLowerCase();

      filtered = filtered.where((vehicle) {
        return (vehicle.regNo ?? "").toLowerCase().contains(search) ||
            (vehicle.makeName ?? "").toLowerCase().contains(search) ||
            (vehicle.modelName ?? "").toLowerCase().contains(search) ||
            (vehicle.variantName ?? "").toLowerCase().contains(search);
      }).toList();
    }

    /// Make
    if (filter.make != null && filter.make!.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        return (vehicle.makeName ?? "")
            .toLowerCase()
            .contains(filter.make!.toLowerCase());
      }).toList();
    }

    /// Model
    if (filter.model != null && filter.model!.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        return (vehicle.modelName ?? "")
            .toLowerCase()
            .contains(filter.model!.toLowerCase());
      }).toList();
    }

    /// Year
    if (filter.year != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.mfgYear == filter.year;
      }).toList();
    }

    /// Owner
    if (filter.owner != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.dealerVehicleInspection?.ownerCount == filter.owner;
      }).toList();
    }

    /// KM Range
    filtered = filtered.where((vehicle) {
      final km = vehicle.kmDriven ?? 0;

      return km >= (filter.minKm ?? 0) && km <= (filter.maxKm ?? 999999);
    }).toList();

    state = LiveListState.data(
      VehicleResponse(
        data: filtered,
        success: true,
        message: '',
      ),
    );
  }

  void clearFilter() {
    state = LiveListState.data(
      VehicleResponse(
        data: List.from(_originalList),
        success: true,
        message: '',
      ),
    );
  }

  Future<void> getLiveStock({
    int? offset,
    int? limit,
  }) async {
    state = const LiveListState.loading();

    try {
      final result = await _getLiveStockUsecase.getLiveListings(
        offset: offset,
        limit: limit,
      );

      result.fold(
        (failure) {
          state = LiveListState.error(failure.msg ?? '');
        },
        (response) {
          _originalList = response.data;
          state = LiveListState.data(response);
        },
      );
    } catch (e) {
      state = LiveListState.error(e.toString());
    }
  }
}
