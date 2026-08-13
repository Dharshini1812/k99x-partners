import 'package:dealer/features/my_listings/domain/usecase/my_stock.dart';
import 'package:dealer/features/my_listings/presentation/logic/my_list/my_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyStockNotifier extends StateNotifier<MyListState> {
  final MyListUsecase _getMyStockUsecase;

  MyStockNotifier({
    required MyListUsecase getMyStockUsecase,
    MyListState? initialState,
  })  : _getMyStockUsecase = getMyStockUsecase,
        super(initialState ?? const MyListState.initial());

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
          state = MyListState.data(response);
        },
      );
    } catch (e) {
      state = MyListState.error(e.toString());
    }
  }
}
