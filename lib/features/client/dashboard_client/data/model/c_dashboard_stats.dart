// lib/features/client/data/model/client_dashboard_model.dart

class ClientDashboardResponseModel {
  final ClientDashboardStats stats;
  final int totalAvailableStocks;
  final bool success;
  final String message;

  ClientDashboardResponseModel({
    required this.stats,
    required this.totalAvailableStocks,
    required this.success,
    required this.message,
  });

  factory ClientDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ClientDashboardResponseModel(
      stats: ClientDashboardStats.fromJson(data['stats'] ?? {}),
      totalAvailableStocks: data['totalAvailableStocks'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class ClientDashboardStats {
  final int totalProcessed;
  final int approvedCount;
  final int pendingCount;
  final double totalDisbursed;
  final int todaysStocks;

  ClientDashboardStats({
    required this.totalProcessed,
    required this.approvedCount,
    required this.pendingCount,
    required this.totalDisbursed,
    required this.todaysStocks,
  });

  factory ClientDashboardStats.fromJson(Map<String, dynamic> json) {
    return ClientDashboardStats(
      totalProcessed: json['totalProcessed'] ?? 0,
      approvedCount: json['approvedCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      totalDisbursed: (json['totalDisbursed'] as num?)?.toDouble() ?? 0.0,
      todaysStocks: json['todaysStocks'] ?? 0,
    );
  }
}
