import 'package:dealer/core/utils/url.dart';
import 'package:dealer/features/dashboard/data/model/d_stats_model.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DashboardDatasource {
  Future<DashboardStats> getStatsCount();
}

class DashboardDatasourceImpl implements DashboardDatasource {
  final Ref ref;

  DashboardDatasourceImpl({required this.ref});
  @override
  Future<DashboardStats> getStatsCount() async {
    try {
      final api = ref.read(apiService);
      const url = Url.statsUrl;
      final response = await api.get2(url);
      final body = DashboardStats.fromJson(response['data']);
      return body;
    } catch (e) {
      rethrow;
    }
  }
}
