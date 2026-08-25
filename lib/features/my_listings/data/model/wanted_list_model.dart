class WantedListResponseModel {
  final WantedDataModel? data;
  final bool success;
  final String message;

  WantedListResponseModel({
    this.data,
    required this.success,
    required this.message,
  });

  factory WantedListResponseModel.fromJson(Map<String, dynamic> json) {
    return WantedListResponseModel(
      data:
          json['data'] != null ? WantedDataModel.fromJson(json['data']) : null,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'success': success,
      'message': message,
    };
  }
}

class WantedDataModel {
  final WantedStatsModel stats;
  final List<WantedListModel> wantedList;

  WantedDataModel({
    required this.stats,
    required this.wantedList,
  });

  factory WantedDataModel.fromJson(Map<String, dynamic> json) {
    return WantedDataModel(
      stats: WantedStatsModel.fromJson(json['stats'] ?? {}),
      wantedList: (json['wantedList'] as List<dynamic>? ?? [])
          .map((e) => WantedListModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'wantedList': wantedList.map((e) => e.toJson()).toList(),
    };
  }
}

class WantedStatsModel {
  final int open;
  final int closed;
  final int matched;

  WantedStatsModel({
    required this.open,
    required this.closed,
    required this.matched,
  });

  factory WantedStatsModel.fromJson(Map<String, dynamic> json) {
    return WantedStatsModel(
      open: json['open'] ?? 0,
      closed: json['closed'] ?? 0,
      matched: json['matched'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'closed': closed,
      'matched': matched,
    };
  }
}

class WantedListModel {
  final int id;
  final int dealerId;
  final String vehicleType;
  final String make;
  final String model;
  final String variant;
  final double budgetFrom;
  final double budgetTo;
  final String neededBy;
  final String notes;
  final String status;
  final String createdAt;
  final String updatedAt;

  WantedListModel({
    required this.id,
    required this.dealerId,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.variant,
    required this.budgetFrom,
    required this.budgetTo,
    required this.neededBy,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WantedListModel.fromJson(Map<String, dynamic> json) {
    return WantedListModel(
      id: json['id'] ?? 0,
      dealerId: json['dealerId'] ?? 0,
      vehicleType: json['vehicleType'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      variant: json['variant'] ?? '',
      budgetFrom: (json['budgetFrom'] ?? 0).toDouble(),
      budgetTo: (json['budgetTo'] ?? 0).toDouble(),
      neededBy: json['neededBy'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dealerId': dealerId,
      'vehicleType': vehicleType,
      'make': make,
      'model': model,
      'variant': variant,
      'budgetFrom': budgetFrom,
      'budgetTo': budgetTo,
      'neededBy': neededBy,
      'notes': notes,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
