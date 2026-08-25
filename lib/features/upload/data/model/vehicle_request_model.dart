import 'package:dio/dio.dart';

class AddVehicleRequestModel {
  final String regNo;
  final String makeName;
  final String modelName;
  final String variantName;
  final int mfgYear;
  final String transmission;
  final String fuelType;
  final int kmDriven;
  final String bodyStyle;
  final int stateId;
  final int cityId;
  final DealerVehicleInspection dealerVehicleInspection;

  AddVehicleRequestModel({
    required this.regNo,
    required this.makeName,
    required this.modelName,
    required this.variantName,
    required this.mfgYear,
    required this.transmission,
    required this.fuelType,
    required this.kmDriven,
    required this.bodyStyle,
    required this.stateId,
    required this.cityId,
    required this.dealerVehicleInspection,
  });

  FormData toFormData() {
    return FormData.fromMap({
      'regNo': regNo,
      'makeName': makeName,
      'modelName': modelName,
      'variantName': variantName,
      'mfgYear': mfgYear,
      'transmission': transmission,
      'fuelType': fuelType,
      'kmDriven': kmDriven,
      'bodyStyle': bodyStyle,
      'stateId': stateId,
      'cityId': cityId,
      'dealerVehicleInspection.rc': dealerVehicleInspection.rc,
      'dealerVehicleInspection.engineCondition':
          dealerVehicleInspection.engineCondition,
      'dealerVehicleInspection.interiorCondition':
          dealerVehicleInspection.interiorCondition,
      'dealerVehicleInspection.exteriorCondition':
          dealerVehicleInspection.exteriorCondition,
      'dealerVehicleInspection.ownerCount': dealerVehicleInspection.ownerCount,
      'dealerVehicleInspection.accidentHistory':
          dealerVehicleInspection.accidentHistory,
      'dealerVehicleInspection.remarks': dealerVehicleInspection.remarks,
      'dealerVehicleInspection.overallCondition':
          dealerVehicleInspection.overallCondition,
    });
  }
}

class DealerVehicleInspection {
  final int rc;
  final double engineCondition;
  final double interiorCondition;
  final double exteriorCondition;
  final int ownerCount;
  final String accidentHistory;
  final String remarks;
  final int overallCondition;

  DealerVehicleInspection({
    required this.rc,
    required this.engineCondition,
    required this.interiorCondition,
    required this.exteriorCondition,
    required this.ownerCount,
    required this.accidentHistory,
    required this.remarks,
    required this.overallCondition,
  });
}
