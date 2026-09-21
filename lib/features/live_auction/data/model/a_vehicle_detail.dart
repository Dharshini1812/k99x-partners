import 'package:dealer/features/live_auction/data/model/live_model.dart'
    show AutobidInfo;

class VehicleDetailResponse {
  final bool success;
  final String message;
  final VehicleDetailData? data;

  VehicleDetailResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VehicleDetailResponse.fromJson(Map<String, dynamic> json) {
    return VehicleDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VehicleDetailData.fromJson(json['data'])
          : null,
    );
  }
}

/// One entry from the `images` array — e.g.
/// {"type": "front_view", "label": "Front", "url": "...",
///  "fileName": "front_view", "fileType": "jpeg"}
class VehicleImage {
  final String? type;
  final String? label;
  final String? url;
  final String? fileName;
  final String? fileType;

  VehicleImage({
    this.type,
    this.label,
    this.url,
    this.fileName,
    this.fileType,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      type: json['type'],
      label: json['label'],
      url: json['url'],
      fileName: json['fileName'],
      fileType: json['fileType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'url': url,
      'fileName': fileName,
      'fileType': fileType,
    };
  }
}

class VehicleDetailData {
  final Lender? lender;
  final List<VehicleImage> images;
  final AutobidInfo? autobid;
  final int activeBiddersCount;
  final int auctionStateId;
  final bool biddingAllowed;
  final bool isWatchlisted;
  final num highestBidAmount;
  final VehicleInfo? vehicle;
  final AuctionInfo? auction;

  VehicleDetailData({
    this.lender,
    required this.images,
    this.autobid,
    required this.activeBiddersCount,
    required this.auctionStateId,
    required this.biddingAllowed,
    required this.isWatchlisted,
    required this.highestBidAmount,
    this.vehicle,
    this.auction,
  });

  factory VehicleDetailData.fromJson(Map<String, dynamic> json) {
    return VehicleDetailData(
      lender: json['lender'] != null ? Lender.fromJson(json['lender']) : null,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((e) => VehicleImage.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      autobid:
          json['autobid'] != null ? AutobidInfo.fromJson(json['autobid']) : null,
      activeBiddersCount: json['activeBiddersCount'] ?? 0,
      auctionStateId: json['auctionStateId'] ?? 0,
      biddingAllowed: json['biddingAllowed'] ?? false,
      isWatchlisted: json['isWatchlisted'] ?? false,
      highestBidAmount: json['highestBidAmount'] ?? 0,
      vehicle: json['vehicle'] != null
          ? VehicleInfo.fromJson(json['vehicle'])
          : null,
      auction: json['auction'] != null
          ? AuctionInfo.fromJson(json['auction'])
          : null,
    );
  }
}

class Lender {
  final int? sno;
  final String? lenderName;
  final String? lenderLogoUrl;

  Lender({this.sno, this.lenderName, this.lenderLogoUrl});

  factory Lender.fromJson(Map<String, dynamic> json) {
    return Lender(
      sno: json['sno'],
      lenderName: json['lenderName'],
      lenderLogoUrl: json['lenderLogoUrl'],
    );
  }
}

class VehicleInfo {
  final String? vehicleId;
  final String? loanNo;
  final String? mfgYear;
  final String? make;
  final String? model;
  final String? variant;
  final String? regno;
  final String? color;
  final String? rcStatus;
  final String? fuel;
  final int? kmsDriven;
  final int? ownerCount;
  final String? transmissionType;
  final String? roadtax;
  final String? hypothecation;
  final String? hypothecationBank;
  final String? duplicateKey;
  final String? chassisNo;
  final String? engineNo;
  final String? pollutionForm;
  final String? rtoCode;
  final String? rtoName;
  final String? fitnesReport;
  final String? insuranceStatus;
  final num? basePrice;
  final String? status;

  VehicleInfo({
    this.vehicleId,
    this.loanNo,
    this.mfgYear,
    this.make,
    this.model,
    this.variant,
    this.regno,
    this.color,
    this.rcStatus,
    this.fuel,
    this.kmsDriven,
    this.ownerCount,
    this.transmissionType,
    this.roadtax,
    this.hypothecation,
    this.hypothecationBank,
    this.duplicateKey,
    this.chassisNo,
    this.engineNo,
    this.pollutionForm,
    this.rtoCode,
    this.rtoName,
    this.fitnesReport,
    this.insuranceStatus,
    this.basePrice,
    this.status,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      vehicleId: json['vehicleId'],
      loanNo: json['loanNo'],
      mfgYear: json['mfgYear'],
      make: json['make'],
      model: json['model'],
      variant: json['variant'],
      regno: json['regno'],
      color: json['color'],
      rcStatus: json['rcStatus'],
      fuel: json['fuel'],
      kmsDriven: json['kmsDriven'],
      ownerCount: json['ownerCount'],
      transmissionType: json['transmissionType'],
      roadtax: json['roadtax'],
      hypothecation: json['hypothecation'],
      hypothecationBank: json['hypothecationBank'],
      duplicateKey: json['duplicateKey'],
      chassisNo: json['chassisNo'],
      engineNo: json['engineNo'],
      pollutionForm: json['pollutionForm'],
      rtoCode: json['rtoCode'],
      rtoName: json['rtoName'],
      fitnesReport: json['fitnesReport'],
      insuranceStatus: json['insuranceStatus'],
      basePrice: json['basePrice'],
      status: json['status'],
    );
  }
}

class AuctionInfo {
  final int? id;
  final String? auctionCalendarId;
  final num? startingPrice;
  final num? currentPrice;
  final int? startTime;
  final int? endTime;
  final String? status;
  final int? totalBids;

  AuctionInfo({
    this.id,
    this.auctionCalendarId,
    this.startingPrice,
    this.currentPrice,
    this.startTime,
    this.endTime,
    this.status,
    this.totalBids,
  });

  factory AuctionInfo.fromJson(Map<String, dynamic> json) {
    return AuctionInfo(
      id: json['id'],
      auctionCalendarId: json['auctionCalendarId'],
      startingPrice: json['startingPrice'],
      currentPrice: json['currentPrice'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      totalBids: json['totalBids'],
    );
  }
}
