import 'package:dealer/core/helper/other_helper.dart';
import 'package:dealer/features/my_listings/data/model/vehicle_list_model.dart';
import 'package:dealer/features/upload/data/model/vehicle_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MAPPING LOGIC
//
// This is the single place responsible for converting the API response model
// (VehicleData) into the upload flow's input model (VehicleListingModel).
// Add missing fields (like city/state) here as your backend team implements
// those endpoints.
// ─────────────────────────────────────────────────────────────────────────────
extension VehicleDataMappingX on VehicleData {
  VehicleListingModel toListingModel() {
    return VehicleListingModel(
      vehicleId: id,
      registrationNumber: regNo,
      year: mfgYear?.toString(),
      mileageKm: kmDriven?.toString(),
      bodyStyle: bodyStyle,
      fuelType: toTitleCase(fuelType),
      transmission: toTitleCase(transmission),

      // MAPPING FROM NESTED INSPECTION MODEL
      engineCondition:
          convertCondition(dealerVehicleInspection?.engineCondition),
      exteriorCondition:
          convertCondition(dealerVehicleInspection?.exteriorCondition),
      interiorCondition:
          convertCondition(dealerVehicleInspection?.interiorCondition),
      numberOfOwners: dealerVehicleInspection?.ownerCount != null
          ? dealerVehicleInspection!.ownerCount!.toString()
          : null,

      savedMakeName: makeName,
      savedModelName: modelName,
      savedVariantName: variantName,
      // Mapping boolean history to dropdown string format
      accidentHistory: dealerVehicleInspection?.accidentHistory,
      savedStateName: stateName,
      savedCityName: cityName,
      savedStateId: stateId,
      savedCityId: cityId,

      //condition

      // MAPPING SAVED URLs
      // IdentificationSpecsStep displays the saved image from this URL.
      // MediaCaptureStep uses these to decide which slots have data already.
      frontImagePath: dealerVehicleInspection?.frontVehicleImageUrl?.url,
      odometerImagePath: dealerVehicleInspection?.odometerImageUrl?.url,
      exteriorVideoPath: dealerVehicleInspection?.exteriorVideoUrl?.url,
      interiorVideoPath: dealerVehicleInspection?.interiorVideoUrl?.url,
      engineBayVideoPath: dealerVehicleInspection?.engineBayVideoUrl?.url,
      tyresVideoPath: dealerVehicleInspection?.tyreVideoUrl?.url,

      dealerExpectedPrice: dealerPrice?.toString(),
      estimatedMarketPrice: marketPrice,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT VEHICLE PROVIDER
//
// Keeps track of the vehicle currently being loaded for edit.
// Use null to indicate "Create New" mode.
// ─────────────────────────────────────────────────────────────────────────────
typedef EditVehicleState = ({VehicleListingModel? model, int refreshKey});

final editVehicleProvider = StateProvider<EditVehicleState>((ref) => (
      model: null,
      refreshKey: 0,
    ));
