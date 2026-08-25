// lib/features/client/presentation/logic/client_stocks_state.dart
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'c_stocks_state.freezed.dart';

@freezed
class ClientStocksState with _$ClientStocksState {
  const factory ClientStocksState.initial() = _ClientStocksInitial;

  /// Only used for the FIRST page load — subsequent pages use the
  /// isLoadingMore flag on the data variant instead, so the existing
  /// list stays visible with a small loader at the bottom rather than
  /// the whole screen flashing back to a spinner.
  const factory ClientStocksState.loading() = _ClientStocksLoading;
  const factory ClientStocksState.data({
    required List<ClientVehicleModel> vehicles,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _ClientStocksData;

  const factory ClientStocksState.error(String msg) = _ClientStocksError;
}
