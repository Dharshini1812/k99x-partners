// lib/features/client/data/model/client_stock_model.dart

class ClientStocksResponseModel {
  final int totalPages;
  final List<ClientVehicleModel> vehicles;
  final int pageSize;
  final int totalCount;
  final int currentPage;
  final bool success;
  final String message;

  ClientStocksResponseModel({
    required this.totalPages,
    required this.vehicles,
    required this.pageSize,
    required this.totalCount,
    required this.currentPage,
    required this.success,
    required this.message,
  });

  factory ClientStocksResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ClientStocksResponseModel(
      totalPages: data['totalPages'] ?? 0,
      vehicles: (data['vehicles'] as List<dynamic>? ?? [])
          .map((e) => ClientVehicleModel.fromJson(e))
          .toList(),
      pageSize: data['pageSize'] ?? 0,
      totalCount: data['totalCount'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// ADAPT: this is a dedicated model for the client-side stock list,
/// separate from the dealer-side VehicleData used elsewhere in this app
/// (my_listings/data/model/vehicle_list_model.dart). A few fields here
/// have a different shape than what that model likely expects —
/// bodyStyle/stateId/cityId are nullable here, and youtubeVideoUrl is an
/// object ({youtubeUrl, thumbnail}) rather than a plain string. If you'd
/// rather unify these into one shared VehicleData model instead of
/// keeping two, show me that model's current source and I'll merge them.
class ClientVehicleModel {
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
  final ClientInspectionModel? dealerVehicleInspection;
  final String? approvedClientName;
  final int? tenureMonths;
  final double? loanAmount;
  final int wantedMatchCount;
  final bool kycExists;
  final String? dealerFirstName;
  final int similarPlatformCount;
  final String? dealerCityName;
  final String? dealerStateName;
  final String? approvedDate;
  final bool clientApproved;
  final double? interestRate;

  ClientVehicleModel({
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
    this.approvedClientName,
    this.tenureMonths,
    this.loanAmount,
    this.wantedMatchCount = 0,
    this.kycExists = false,
    this.dealerFirstName,
    this.similarPlatformCount = 0,
    this.dealerCityName,
    this.dealerStateName,
    this.approvedDate,
    this.clientApproved = false,
    this.interestRate,
  });

  factory ClientVehicleModel.fromJson(Map<String, dynamic> json) {
    return ClientVehicleModel(
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
          ? ClientInspectionModel.fromJson(json['dealerVehicleInspection'])
          : null,
      approvedClientName: json['approvedClientName'],
      tenureMonths: json['tenureMonths'],
      loanAmount: (json['loanAmount'] as num?)?.toDouble(),
      wantedMatchCount: json['wantedMatchCount'] ?? 0,
      kycExists: json['kycExists'] ?? false,
      dealerFirstName: json['dealerFirstName'],
      similarPlatformCount: json['similarPlatformCount'] ?? 0,
      dealerCityName: json['dealerCityName'],
      dealerStateName: json['dealerStateName'],
      approvedDate: json['approvedDate'],
      clientApproved: json['clientApproved'] ?? false,
      interestRate: (json['interestRate'] as num?)?.toDouble(),
    );
  }
}

class ClientInspectionModel {
  final String? id;
  final int? odometer;
  final String? engineCondition;
  final String? interiorCondition;
  final String? accidentHistory;
  final String? exteriorCondition;
  final int? ownerCount;
  final ClientMediaFile? frontVehicleImageUrl;
  final ClientMediaFile? odometerImageUrl;
  final ClientMediaFile? exteriorVideoUrl;
  final ClientMediaFile? interiorVideoUrl;
  final ClientMediaFile? engineBayVideoUrl;
  final ClientMediaFile? tyreVideoUrl;
  final ClientYoutubeVideo? youtubeVideoUrl;
  final int? rc;
  final int? overallCondition;
  final String? remarks;

  ClientInspectionModel({
    this.id,
    this.odometer,
    this.engineCondition,
    this.interiorCondition,
    this.accidentHistory,
    this.exteriorCondition,
    this.ownerCount,
    this.frontVehicleImageUrl,
    this.odometerImageUrl,
    this.exteriorVideoUrl,
    this.interiorVideoUrl,
    this.engineBayVideoUrl,
    this.tyreVideoUrl,
    this.youtubeVideoUrl,
    this.rc,
    this.overallCondition,
    this.remarks,
  });

  factory ClientInspectionModel.fromJson(Map<String, dynamic> json) {
    return ClientInspectionModel(
      id: json['id'],
      odometer: json['odometer'],
      engineCondition: json['engineCondition'],
      interiorCondition: json['interiorCondition'],
      accidentHistory: json['accidentHistory'],
      exteriorCondition: json['exteriorCondition'],
      ownerCount: json['ownerCount'],
      frontVehicleImageUrl:
          ClientMediaFile.tryParse(json['frontVehicleImageUrl']),
      odometerImageUrl: ClientMediaFile.tryParse(json['odometerImageUrl']),
      exteriorVideoUrl: ClientMediaFile.tryParse(json['exteriorVideoUrl']),
      interiorVideoUrl: ClientMediaFile.tryParse(json['interiorVideoUrl']),
      engineBayVideoUrl: ClientMediaFile.tryParse(json['engineBayVideoUrl']),
      tyreVideoUrl: ClientMediaFile.tryParse(json['tyreVideoUrl']),
      youtubeVideoUrl: json['youtubeVideoUrl'] != null
          ? ClientYoutubeVideo.fromJson(json['youtubeVideoUrl'])
          : null,
      rc: json['rc'],
      overallCondition: json['overallCondition'],
      remarks: json['remarks'],
    );
  }
}

class ClientMediaFile {
  final String? fileName;
  final String? type;
  final String? url;
  final String? publicId;

  ClientMediaFile({this.fileName, this.type, this.url, this.publicId});

  factory ClientMediaFile.fromJson(Map<String, dynamic> json) {
    return ClientMediaFile(
      fileName: json['fileName'],
      type: json['type'],
      url: json['url'],
      publicId: json['public_id'],
    );
  }

  static ClientMediaFile? tryParse(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return null;
    return ClientMediaFile.fromJson(json);
  }
}

/// Different shape from the dealer-side youtubeVideoUrl seen earlier
/// (which was a plain string) — here it's an object.
class ClientYoutubeVideo {
  final String? youtubeUrl;
  final String? thumbnail;

  ClientYoutubeVideo({this.youtubeUrl, this.thumbnail});

  factory ClientYoutubeVideo.fromJson(Map<String, dynamic> json) {
    return ClientYoutubeVideo(
      youtubeUrl: json['youtubeUrl'],
      thumbnail: json['thumbnail'],
    );
  }
}
