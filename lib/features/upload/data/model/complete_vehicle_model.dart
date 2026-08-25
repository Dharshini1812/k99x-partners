// lib/features/upload/data/model/complete_vehicle_model.dart

import 'package:dio/dio.dart';

class CompleteVehicleRequestModel {
  final String vehicleId;
  final double dealerPrice;

  CompleteVehicleRequestModel({
    required this.vehicleId,
    required this.dealerPrice,
  });

  FormData toFormData() {
    return FormData.fromMap({
      'vehicleId': vehicleId,
      'dealerPrice': dealerPrice.toStringAsFixed(2),
    });
  }
}

class CompleteVehicleResponseModel {
  final bool success;
  final String message;

  CompleteVehicleResponseModel({
    required this.success,
    required this.message,
  });

  factory CompleteVehicleResponseModel.fromJson(Map<String, dynamic> json) {
    return CompleteVehicleResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
