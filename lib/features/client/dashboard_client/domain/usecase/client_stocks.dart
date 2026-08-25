import 'package:dartz/dartz.dart';
import 'package:dealer/core/error/failure.dart';
import 'package:dealer/features/client/dashboard_client/domain/repository/repository.dart';
import 'package:dealer/features/client/dealer_stocks/data/model/c_stocks.dart';

class GetClientStocks {
  final ClientRepository repository;
  GetClientStocks(this.repository);

  Future<Either<Failure, ClientStocksResponseModel>> call({
    required int page,
    int limit = 10,
  }) {
    return repository.getStocks(page: page, limit: limit);
  }
}
