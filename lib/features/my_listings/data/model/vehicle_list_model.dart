class VehicleResponse {
  final List<VehicleData> data;
  final bool success;
  final String message;

  VehicleResponse({
    required this.data,
    required this.success,
    required this.message,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => VehicleData.fromJson(e))
          .toList(),
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'success': success,
        'message': message,
      };
}

class VehicleData {
  final String? id;
  final int? dealerId;
  final String? regNo;

  final int? make;
  final String? makeName;

  final int? model;
  final String? modelName;

  final int? variant;
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

  final DealerVehicleInspection? dealerVehicleInspection;

  final String? approvedClientName;
  final String? approvedLoanDetails;

  final int? tenureMonths;
  final double? loanAmount;

  final int? wantedMatchCount;
  final List<WantedMatchList>? wantedMatchesDetails;

  final bool? kycExists;

  final String? dealerFirstName;

  final int? similarPlatformCount;
  final String? similarPlatformDetails;

  final String? physicalInspectionReport;
  final String? report;

  final String? dealerCityName;
  final String? dealerStateName;

  final String? approvedDate;
  final double? interestRate;
  final List<AllLoanOffers>? allLoanOffers;

  VehicleData({
    this.id,
    this.dealerId,
    this.regNo,
    this.make,
    this.makeName,
    this.model,
    this.modelName,
    this.variant,
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
    this.approvedLoanDetails,
    this.tenureMonths,
    this.loanAmount,
    this.wantedMatchCount,
    this.wantedMatchesDetails,
    this.kycExists,
    this.dealerFirstName,
    this.similarPlatformCount,
    this.similarPlatformDetails,
    this.physicalInspectionReport,
    this.report,
    this.dealerCityName,
    this.dealerStateName,
    this.approvedDate,
    this.interestRate,
    this.allLoanOffers,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
        id: json['id'],
        dealerId: json['dealerId'],
        regNo: json['regNo'],
        make: json['make'],
        makeName: json['makeName'],
        model: json['model'],
        modelName: json['modelName'],
        variant: json['variant'],
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
            ? DealerVehicleInspection.fromJson(json['dealerVehicleInspection'])
            : null,
        approvedClientName: json['approvedClientName'],
        approvedLoanDetails: json['approvedLoanDetails'],
        tenureMonths: json['tenureMonths'],
        loanAmount: (json['loanAmount'] as num?)?.toDouble(),
        wantedMatchCount: json['wantedMatchCount'],
        wantedMatchesDetails: (json['wantedMatchesList'] as List<dynamic>)
            .map((e) => WantedMatchList.fromJson(e))
            .toList(),
        kycExists: json['kycExists'],
        dealerFirstName: json['dealerFirstName'],
        similarPlatformCount: json['similarPlatformCount'],
        similarPlatformDetails: json['similarPlatformDetails'],
        physicalInspectionReport: json['physicalInspectionReport'],
        report: json['report'],
        dealerCityName: json['dealerCityName'],
        dealerStateName: json['dealerStateName'],
        approvedDate: json['approvedDate'],
        interestRate: (json['interestRate'] as num?)?.toDouble(),
        allLoanOffers: json['allLoanOffers'] != null
            ? (json['allLoanOffers'] as List)
                .map((e) => AllLoanOffers.fromJson(e))
                .toList()
            : null);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dealerId': dealerId,
        'regNo': regNo,
        'make': make,
        'makeName': makeName,
        'model': model,
        'modelName': modelName,
        'variant': variant,
        'variantName': variantName,
        'mfgYear': mfgYear,
        'bodyStyle': bodyStyle,
        'fuelType': fuelType,
        'transmission': transmission,
        'kmDriven': kmDriven,
        'dealerPrice': dealerPrice,
        'marketPrice': marketPrice,
        'stateId': stateId,
        'stateName': stateName,
        'cityId': cityId,
        'cityName': cityName,
        'status': status,
        'color': color,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'dealerVehicleInspection': dealerVehicleInspection?.toJson(),
        'approvedClientName': approvedClientName,
        'approvedLoanDetails': approvedLoanDetails,
        'tenureMonths': tenureMonths,
        'loanAmount': loanAmount,
        'wantedMatchCount': wantedMatchCount,
        'wantedMatchesDetails': wantedMatchesDetails,
        'kycExists': kycExists,
        'dealerFirstName': dealerFirstName,
        'similarPlatformCount': similarPlatformCount,
        'similarPlatformDetails': similarPlatformDetails,
        'physicalInspectionReport': physicalInspectionReport,
        'report': report,
        'dealerCityName': dealerCityName,
        'dealerStateName': dealerStateName,
        'approvedDate': approvedDate,
        'interestRate': interestRate,
      };
}

class DealerVehicleInspection {
  final int? id;
  final String? vehicleId;
  final int? dealerId;
  final int? odometer;

  final String? engineCondition;
  final String? interiorCondition;
  final String? accidentHistory;
  final String? exteriorCondition;

  final int? ownerCount;

  final MediaFile? frontVehicleImageUrl;
  final MediaFile? odometerImageUrl;

  final MediaFile? exteriorVideoUrl;
  final MediaFile? interiorVideoUrl;
  final MediaFile? engineBayVideoUrl;
  final MediaFile? tyreVideoUrl;
  final MediaFile? mergedVideoUrl;

  final String? youtubeVideoUrl;
  final String? displaySt;

  final int? createdAt;
  final int? updatedAt;

  final int? rc;
  final int? overallCondition;

  final String? remarks;

  DealerVehicleInspection({
    this.id,
    this.vehicleId,
    this.dealerId,
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
    this.mergedVideoUrl,
    this.youtubeVideoUrl,
    this.displaySt,
    this.createdAt,
    this.updatedAt,
    this.rc,
    this.overallCondition,
    this.remarks,
  });

  factory DealerVehicleInspection.fromJson(Map<String, dynamic> json) {
    return DealerVehicleInspection(
      id: json['id'],
      vehicleId: json['vehicleId']?.toString(),
      dealerId: json['dealerId'],
      odometer: json['odometer'],
      engineCondition: json['engineCondition']?.toString(),
      interiorCondition: json['interiorCondition']?.toString(),
      accidentHistory: json['accidentHistory']?.toString(),
      exteriorCondition: json['exteriorCondition']?.toString(),
      ownerCount: json['ownerCount'],
      frontVehicleImageUrl: json['frontVehicleImageUrl'] != null
          ? MediaFile.fromJson(json['frontVehicleImageUrl'])
          : null,
      odometerImageUrl: json['odometerImageUrl'] != null
          ? MediaFile.fromJson(json['odometerImageUrl'])
          : null,
      exteriorVideoUrl: json['exteriorVideoUrl'] != null
          ? MediaFile.fromJson(json['exteriorVideoUrl'])
          : null,
      interiorVideoUrl: json['interiorVideoUrl'] != null
          ? MediaFile.fromJson(json['interiorVideoUrl'])
          : null,
      engineBayVideoUrl: json['engineBayVideoUrl'] != null
          ? MediaFile.fromJson(json['engineBayVideoUrl'])
          : null,
      tyreVideoUrl: json['tyreVideoUrl'] != null
          ? MediaFile.fromJson(json['tyreVideoUrl'])
          : null,
      mergedVideoUrl: json['mergedVideoUrl'] != null
          ? MediaFile.fromJson(json['mergedVideoUrl'])
          : null,
      youtubeVideoUrl: json['youtubeVideoUrl']?.toString(),
      displaySt: json['displaySt']?.toString(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rc: json['rc'],
      overallCondition: json['overallCondition'],
      remarks: json['remarks']?.toString(),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'dealerId': dealerId,
        'odometer': odometer,
        'engineCondition': engineCondition,
        'interiorCondition': interiorCondition,
        'accidentHistory': accidentHistory,
        'exteriorCondition': exteriorCondition,
        'ownerCount': ownerCount,
        'frontVehicleImageUrl': frontVehicleImageUrl?.toJson(),
        'odometerImageUrl': odometerImageUrl?.toJson(),
        'exteriorVideoUrl': exteriorVideoUrl?.toJson(),
        'interiorVideoUrl': interiorVideoUrl?.toJson(),
        'engineBayVideoUrl': engineBayVideoUrl?.toJson(),
        'tyreVideoUrl': tyreVideoUrl?.toJson(),
        'mergedVideoUrl': mergedVideoUrl?.toJson(),
        'youtubeVideoUrl': youtubeVideoUrl,
        'displaySt': displaySt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'rc': rc,
        'overallCondition': overallCondition,
        'remarks': remarks,
      };
}

class MediaFile {
  final String? fileName;
  final String? type;
  final String? url;
  final String? publicId;

  MediaFile({
    this.fileName,
    this.type,
    this.url,
    this.publicId,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      fileName: json['fileName'],
      type: json['type'],
      url: json['url'],
      publicId: json['public_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'type': type,
        'url': url,
        'public_id': publicId,
      };
}

class AllLoanOffers {
  double? interestRate;
  int? tenureMonths;
  String? lenderName;
  double? loanAmount;

  AllLoanOffers(
      {this.interestRate, this.tenureMonths, this.lenderName, this.loanAmount});

  AllLoanOffers.fromJson(Map<String, dynamic> json) {
    interestRate = json['interestRate'];
    tenureMonths = json['tenureMonths'];
    lenderName = json['lenderName'];
    loanAmount = json['loanAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['interestRate'] = interestRate;
    data['tenureMonths'] = tenureMonths;
    data['lenderName'] = lenderName;
    data['loanAmount'] = loanAmount;
    return data;
  }
}

class WantedMatchList {
  String? createdAt;
  String? dealerName;
  String? phoneNumber;
  String? notes;
  String? city;
  String? dealerId;
  double? budgetFrom;
  String? state;
  double? budgetTo;
  String? neededBy;

  WantedMatchList(
      {this.createdAt,
      this.dealerName,
      this.phoneNumber,
      this.notes,
      this.city,
      this.dealerId,
      this.budgetFrom,
      this.state,
      this.budgetTo,
      this.neededBy});

  WantedMatchList.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    dealerName = json['dealerName'];
    phoneNumber = json['phoneNumber'];
    notes = json['notes'];
    city = json['city'];
    dealerId = json['dealerId'];
    budgetFrom = json['budgetFrom'];
    state = json['state'];
    budgetTo = json['budgetTo'];
    neededBy = json['neededBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['dealerName'] = dealerName;
    data['phoneNumber'] = phoneNumber;
    data['notes'] = notes;
    data['city'] = city;
    data['dealerId'] = dealerId;
    data['budgetFrom'] = budgetFrom;
    data['state'] = state;
    data['budgetTo'] = budgetTo;
    data['neededBy'] = neededBy;
    return data;
  }
}
