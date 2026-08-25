import 'package:dealer/features/client/dashboard_client/domain/usecase/client_stocks.dart';
import 'package:dealer/features/client/dashboard_client/presentation/logic/c_stocks/c_stocks_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientStocksNotifier extends StateNotifier<ClientStocksState> {
  final GetClientStocks _usecase;
  static const _limit = 100;

  int _currentPage = 1;

  ClientStocksNotifier({required GetClientStocks usecase})
      : _usecase = usecase,
        super(const ClientStocksState.initial());

  Future<void> fetchFirstPage() async {
    _currentPage = 1;
    state = const ClientStocksState.loading();

    final result = await _usecase(page: _currentPage, limit: _limit);

    result.fold(
      (failure) {
        state = ClientStocksState.error(failure.msg ?? 'Could not load stocks');
      },
      (response) {
        state = ClientStocksState.data(
          vehicles: response.vehicles,
          hasMore: response.currentPage < response.totalPages,
        );
      },
    );
  }

  /// No-op if already loading, there's no more data, or the current
  /// state isn't the data variant yet (e.g. still on the first load).
  Future<void> loadNextPage() async {
    final current = state.whenOrNull(
      data: (vehicles, hasMore, isLoadingMore) =>
          (vehicles, hasMore, isLoadingMore),
    );
    if (current == null) return;

    final (vehicles, hasMore, isLoadingMore) = current;
    if (!hasMore || isLoadingMore) return;

    state = ClientStocksState.data(
      vehicles: vehicles,
      hasMore: hasMore,
      isLoadingMore: true,
    );

    final nextPage = _currentPage + 1;
    final result = await _usecase(page: nextPage, limit: _limit);

    result.fold(
      (failure) {
        // Keep the existing list on failure — just stop the bottom
        // loader. The user can trigger another load-more attempt by
        // scrolling again (or wire a retry affordance if you want one).
        state = ClientStocksState.data(
          vehicles: vehicles,
          hasMore: hasMore,
          isLoadingMore: false,
        );
      },
      (response) {
        _currentPage = nextPage;
        state = ClientStocksState.data(
          vehicles: [...vehicles, ...response.vehicles],
          hasMore: response.currentPage < response.totalPages,
          isLoadingMore: false,
        );
      },
    );
  }
}
