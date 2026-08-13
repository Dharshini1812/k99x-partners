class DashboardStatsResponse {
  DashboardStats? data;
  bool? success;
  String? message;

  DashboardStatsResponse({
    this.data,
    this.success,
    this.message,
  });

  DashboardStatsResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? DashboardStats.fromJson(json['data']) : null;
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'success': success,
      'message': message,
    };
  }
}

class DashboardStats {
  double? totalEarnings;
  int? totalLiveVehicles;
  int? totalVehicles;
  int? totalSoldVehicles;

  DashboardStats({
    this.totalEarnings,
    this.totalLiveVehicles,
    this.totalVehicles,
    this.totalSoldVehicles,
  });

  DashboardStats.fromJson(Map<String, dynamic> json) {
    totalEarnings = (json['totalEarnings'] as num?)?.toDouble();
    totalLiveVehicles = json['totalLiveVehicles'];
    totalVehicles = json['totalVehicles'];
    totalSoldVehicles = json['totalSoldVehicles'];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'totalLiveVehicles': totalLiveVehicles,
      'totalVehicles': totalVehicles,
      'totalSoldVehicles': totalSoldVehicles,
    };
  }
}
