// lib/features/upload/data/model/review_response_model.dart

class ReviewResponseModel {
  final ReviewData data;
  final bool success;
  final String message;

  ReviewResponseModel({
    required this.data,
    required this.success,
    required this.message,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      data: ReviewData.fromJson(json['data'] ?? {}),
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class ReviewData {
  final VehicleReviewModel vehicle;
  final InspectionModel inspection;

  ReviewData({required this.vehicle, required this.inspection});

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      vehicle: VehicleReviewModel.fromJson(json['vehicle'] ?? {}),
      inspection: InspectionModel.fromJson(json['inspection'] ?? {}),
    );
  }
}

/// ADAPT: this covers the fields visible in your sample response. There
/// were several I left out on purpose since I couldn't tell their real
/// use from one sample (approvedClientName, wantedMatchesDetails,
/// physicalInspectionReport, report, etc.) — add them the same way if the
/// Review screen ends up needing them.
class VehicleReviewModel {
  final String id;
  final int? dealerId;
  final String? regNo;
  final String? makeName;
  final String? modelName;
  final String? variantName;
  final int? mfgYear;
  final String? bodyStyle;
  final String? fuelType;
  final String? transmission;
  final int? kmDriven;
  final double? dealerPrice;
  final double? marketPrice;
  final int? stateId;
  final String? stateName;
  final int? cityId;
  final String? cityName;
  final String? status;
  final String? color;
  final int? createdAt;
  final int? updatedAt;
  final InspectionModel? dealerVehicleInspection;
  final String? dealerFirstName;
  final String? dealerCityName;
  final String? dealerStateName;
  final bool kycExists;
  final bool clientApproved;

  VehicleReviewModel({
    required this.id,
    this.dealerId,
    this.regNo,
    this.makeName,
    this.modelName,
    this.variantName,
    this.mfgYear,
    this.bodyStyle,
    this.fuelType,
    this.transmission,
    this.kmDriven,
    this.dealerPrice,
    this.marketPrice,
    this.stateId,
    this.stateName,
    this.cityId,
    this.cityName,
    this.status,
    this.color,
    this.createdAt,
    this.updatedAt,
    this.dealerVehicleInspection,
    this.dealerFirstName,
    this.dealerCityName,
    this.dealerStateName,
    this.kycExists = false,
    this.clientApproved = false,
  });

  factory VehicleReviewModel.fromJson(Map<String, dynamic> json) {
    return VehicleReviewModel(
      id: json['id'] ?? '',
      dealerId: json['dealerId'],
      regNo: json['regNo'],
      makeName: json['makeName'],
      modelName: json['modelName'],
      variantName: json['variantName'],
      mfgYear: json['mfgYear'],
      bodyStyle: json['bodyStyle'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      kmDriven: json['kmDriven'],
      dealerPrice: (json['dealerPrice'] as num?)?.toDouble(),
      marketPrice: (json['marketPrice'] as num?)?.toDouble(),
      stateId: json['stateId'],
      stateName: json['stateName'],
      cityId: json['cityId'],
      cityName: json['cityName'],
      status: json['status'],
      color: json['color'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      dealerVehicleInspection: json['dealerVehicleInspection'] != null
          ? InspectionModel.fromJson(json['dealerVehicleInspection'])
          : null,
      dealerFirstName: json['dealerFirstName'],
      dealerCityName: json['dealerCityName'],
      dealerStateName: json['dealerStateName'],
      kycExists: json['kycExists'] ?? false,
      clientApproved: json['clientApproved'] ?? false,
    );
  }
}

class InspectionModel {
  final String? id;
  final String? vehicleId;
  final int? dealerId;
  final int? odometer;
  final String? engineCondition;
  final String? interiorCondition;
  final String? exteriorCondition;
  final String? accidentHistory;
  final int? ownerCount;
  final MediaFile? frontVehicleImageUrl;
  final MediaFile? odometerImageUrl;
  final MediaFile? exteriorVideoUrl;
  final MediaFile? interiorVideoUrl;
  final MediaFile? engineBayVideoUrl;
  final MediaFile? tyreVideoUrl;
  final MergedVideoModel? mergedVideoUrl;
  final String? youtubeVideoUrl;
  final int? createdAt;
  final int? updatedAt;
  final int? rc;
  final int? overallCondition;
  final String? remarks;

  InspectionModel({
    this.id,
    this.vehicleId,
    this.dealerId,
    this.odometer,
    this.engineCondition,
    this.interiorCondition,
    this.exteriorCondition,
    this.accidentHistory,
    this.ownerCount,
    this.frontVehicleImageUrl,
    this.odometerImageUrl,
    this.exteriorVideoUrl,
    this.interiorVideoUrl,
    this.engineBayVideoUrl,
    this.tyreVideoUrl,
    this.mergedVideoUrl,
    this.youtubeVideoUrl,
    this.createdAt,
    this.updatedAt,
    this.rc,
    this.overallCondition,
    this.remarks,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'],
      vehicleId: json['vehicleId'],
      dealerId: json['dealerId'],
      odometer: json['odometer'],
      engineCondition: json['engineCondition'],
      interiorCondition: json['interiorCondition'],
      exteriorCondition: json['exteriorCondition'],
      accidentHistory: json['accidentHistory'],
      ownerCount: json['ownerCount'],
      frontVehicleImageUrl: MediaFile.tryParse(json['frontVehicleImageUrl']),
      odometerImageUrl: MediaFile.tryParse(json['odometerImageUrl']),
      exteriorVideoUrl: MediaFile.tryParse(json['exteriorVideoUrl']),
      interiorVideoUrl: MediaFile.tryParse(json['interiorVideoUrl']),
      engineBayVideoUrl: MediaFile.tryParse(json['engineBayVideoUrl']),
      tyreVideoUrl: MediaFile.tryParse(json['tyreVideoUrl']),
      mergedVideoUrl: json['mergedVideoUrl'] != null
          ? MergedVideoModel.fromJson(json['mergedVideoUrl'])
          : null,
      youtubeVideoUrl: json['youtubeVideoUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rc: json['rc'],
      overallCondition: json['overallCondition'],
      remarks: json['remarks'],
    );
  }
}

/// One shape used for every image/video slot (front image, odometer
/// image, exterior/interior/engine bay/tyre video).
class MediaFile {
  final String? fileName;
  final String? type;
  final String? url;
  final String? publicId;

  MediaFile({this.fileName, this.type, this.url, this.publicId});

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      fileName: json['fileName'],
      type: json['type'],
      url: json['url'],
      publicId: json['public_id'],
    );
  }

  /// Returns null instead of throwing if the field is missing/null in the
  /// response — every media slot is optional until that step's upload
  /// succeeds.
  static MediaFile? tryParse(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return null;
    return MediaFile.fromJson(json);
  }
}

/// mergedVideoUrl's shape varies — sometimes a full MediaFile-like object,
/// sometimes just `{"status": "ERROR"}` while merging is in progress or
/// failed. Modeling both instead of picking one avoids a parse crash when
/// the field is mid-processing.
class MergedVideoModel {
  final String? status;
  final String? fileName;
  final String? type;
  final String? url;
  final String? publicId;

  MergedVideoModel({
    this.status,
    this.fileName,
    this.type,
    this.url,
    this.publicId,
  });

  factory MergedVideoModel.fromJson(Map<String, dynamic> json) {
    return MergedVideoModel(
      status: json['status'],
      fileName: json['fileName'],
      type: json['type'],
      url: json['url'],
      publicId: json['public_id'],
    );
  }

  bool get isReady => url != null && url!.isNotEmpty;
  bool get isError => status == 'ERROR';
}
