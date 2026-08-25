// lib/features/upload/data/model/edit_vehicle_response_model.dart
//
// Thin wrapper around the existing VehicleData model (from
// my_listings/data/model/vehicle_list_model.dart) — the /edit endpoint's
// {data: {vehicle: {...}}, success, message} shape matches VehicleData's
// existing fromJson exactly, so this just needs to unwrap the extra
// nesting and hand back something with success/message alongside it.

import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';

class EditVehicleResponseModel {
  final VehicleData vehicle;
  final bool success;
  final String message;

  EditVehicleResponseModel({
    required this.vehicle,
    required this.success,
    required this.message,
  });

  factory EditVehicleResponseModel.fromJson(Map<String, dynamic> json) {
    return EditVehicleResponseModel(
      vehicle: VehicleData.fromJson(json['data']?['vehicle'] ?? {}),
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
