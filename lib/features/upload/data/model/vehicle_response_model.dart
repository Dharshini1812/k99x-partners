class AddVehicleResponseModel {
  final AddVehicleData? data;
  final bool success;
  final String message;

  AddVehicleResponseModel({
    this.data,
    required this.success,
    required this.message,
  });

  factory AddVehicleResponseModel.fromJson(Map<String, dynamic> json) {
    return AddVehicleResponseModel(
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AddVehicleData.fromJson(json['data'])
          : null,
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

class AddVehicleData {
  final String vehicleId;

  AddVehicleData({
    required this.vehicleId,
  });

  factory AddVehicleData.fromJson(Map<String, dynamic> json) {
    return AddVehicleData(
      vehicleId: json['vehicleId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
    };
  }
}
