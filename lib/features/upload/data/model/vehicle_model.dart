// lib/features/upload/data/model/vehicle_listing_model.dart
import 'package:dealer/core/common/data/model/city_model.dart';
import 'package:dealer/core/common/data/model/state_model.dart';

class VehicleListingModel {
  // Identification
  final String? registrationNumber;

  // Specifications
  final String? year;
  final String? make; // stores id (API-driven, like your CV/4W make dropdown)
  final String? model; // stores id
  final String? variant; // stores id
  final String? mileageKm;
  final String? bodyStyle;
  final String? fuelType;
  final String? transmission;
  final String? state;
  final String? city;
  final StateModel? selectedState;
  final CityModel? selectedCity;

  // Self Inspection
  final String? engineCondition;
  final String? exteriorCondition;
  final String? interiorCondition;
  final String? numberOfOwners;
  final String? accidentHistory;

  // Photos & Videos
  final String? frontImagePath;
  final String? odometerImagePath;
  final String? exteriorVideoPath;
  final String? interiorVideoPath;
  final String? engineBayVideoPath;
  final String? tyresVideoPath;

  // Review
  final double? estimatedMarketPrice;
  final String? dealerExpectedPrice;
  final bool agreedToTerms;

  const VehicleListingModel({
    this.registrationNumber,
    this.year,
    this.make,
    this.model,
    this.variant,
    this.mileageKm,
    this.bodyStyle,
    this.fuelType,
    this.transmission,
    this.state,
    this.city,
    this.engineCondition,
    this.exteriorCondition,
    this.interiorCondition,
    this.numberOfOwners,
    this.accidentHistory,
    this.frontImagePath,
    this.odometerImagePath,
    this.exteriorVideoPath,
    this.interiorVideoPath,
    this.engineBayVideoPath,
    this.tyresVideoPath,
    this.estimatedMarketPrice,
    this.dealerExpectedPrice,
    this.agreedToTerms = false,
    this.selectedCity,
    this.selectedState,
  });

  VehicleListingModel copyWith({
    String? registrationNumber,
    String? year,
    String? make,
    String? model,
    String? variant,
    String? mileageKm,
    String? bodyStyle,
    String? fuelType,
    String? transmission,
    String? state,
    String? city,
    String? engineCondition,
    String? exteriorCondition,
    String? interiorCondition,
    String? numberOfOwners,
    String? accidentHistory,
    String? frontImagePath,
    String? odometerImagePath,
    String? exteriorVideoPath,
    String? interiorVideoPath,
    String? engineBayVideoPath,
    String? tyresVideoPath,
    double? estimatedMarketPrice,
    String? dealerExpectedPrice,
    bool? agreedToTerms,
    StateModel? selectedState,
    CityModel? selectedCity,
  }) {
    return VehicleListingModel(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      year: year ?? this.year,
      make: make ?? this.make,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      mileageKm: mileageKm ?? this.mileageKm,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      state: state ?? this.state,
      city: city ?? this.city,
      engineCondition: engineCondition ?? this.engineCondition,
      exteriorCondition: exteriorCondition ?? this.exteriorCondition,
      interiorCondition: interiorCondition ?? this.interiorCondition,
      numberOfOwners: numberOfOwners ?? this.numberOfOwners,
      accidentHistory: accidentHistory ?? this.accidentHistory,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      odometerImagePath: odometerImagePath ?? this.odometerImagePath,
      exteriorVideoPath: exteriorVideoPath ?? this.exteriorVideoPath,
      interiorVideoPath: interiorVideoPath ?? this.interiorVideoPath,
      engineBayVideoPath: engineBayVideoPath ?? this.engineBayVideoPath,
      tyresVideoPath: tyresVideoPath ?? this.tyresVideoPath,
      estimatedMarketPrice: estimatedMarketPrice ?? this.estimatedMarketPrice,
      dealerExpectedPrice: dealerExpectedPrice ?? this.dealerExpectedPrice,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }

  // For later API integration — adjust keys to match your backend contract
  Map<String, dynamic> toJson() => {
        'registrationNumber': registrationNumber,
        'year': year,
        'make': make,
        'model': model,
        'variant': variant,
        'mileageKm': mileageKm,
        'bodyStyle': bodyStyle,
        'fuelType': fuelType,
        'transmission': transmission,
        'state': state,
        'city': city,
        'engineCondition': engineCondition,
        'exteriorCondition': exteriorCondition,
        'interiorCondition': interiorCondition,
        'numberOfOwners': numberOfOwners,
        'accidentHistory': accidentHistory,
        'dealerExpectedPrice': dealerExpectedPrice,
        'agreedToTerms': agreedToTerms,
        // media paths uploaded separately, URLs attached after upload
      };
}
