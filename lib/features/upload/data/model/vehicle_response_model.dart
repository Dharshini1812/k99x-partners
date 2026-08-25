class AddVehicleResponseModel {
  final AddVehicleData data;
  final bool success;
  final String message;

  AddVehicleResponseModel({
    required this.data,
    required this.success,
    required this.message,
  });

  factory AddVehicleResponseModel.fromJson(Map<String, dynamic> json) {
    return AddVehicleResponseModel(
      data: AddVehicleData.fromJson(json['data']),
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
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
      vehicleId: json['vehicleId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
    };
  }
}
