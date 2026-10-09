class WatchlistUpdateResponseModel {
  final bool? success;
  final String? message;

  WatchlistUpdateResponseModel({
    this.success,
    this.message,
  });

  factory WatchlistUpdateResponseModel.fromJson(Map<String, dynamic> json) =>
      WatchlistUpdateResponseModel(
        success: json['success'] as bool?,
        message: json['message']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
      };
}

class WatchlistFetchResponseModel {
  final WatchlistData? data;
  final bool? success;
  final String? message;

  WatchlistFetchResponseModel({
    this.data,
    this.success,
    this.message,
  });

  factory WatchlistFetchResponseModel.fromJson(Map<String, dynamic> json) =>
      WatchlistFetchResponseModel(
        data:
            json['data'] != null ? WatchlistData.fromJson(json['data']) : null,
        success: json['success'] as bool?,
        message: json['message']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
        'success': success,
        'message': message,
      };
}

class WatchlistData {
  final List<WatchlistVehicleItem>? vehicles;
  final int? totalCount;

  WatchlistData({
    this.vehicles,
    this.totalCount,
  });

  factory WatchlistData.fromJson(Map<String, dynamic> json) => WatchlistData(
        vehicles: json['vehicles'] != null
            ? (json['vehicles'] as List<dynamic>)
                .map((e) =>
                    WatchlistVehicleItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        totalCount: (json['totalCount'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'vehicles': vehicles?.map((e) => e.toJson()).toList(),
        'totalCount': totalCount,
      };
}

class WatchlistVehicleItem {
  final Vehicle? vehicle;
  final dynamic lender;
  final dynamic vehicleInspection;
  final VehicleImages? vehicleImages;
  final Auction? auction;
  final dynamic autobid;
  final String? state;
  final String? city;
  final String? category;
  final String? frontImage;
  final String? backImage;
  final String? interiorImage;
  final String? engineImage;
  final int? makeId;
  final int? modelId;
  final int? variantId;
  final int? rank;
  final bool? watchlist;
  final double? dealerMaxBid;
  final double? userHighestPrice;
  final bool? userHasBid;

  WatchlistVehicleItem({
    this.vehicle,
    this.lender,
    this.vehicleInspection,
    this.vehicleImages,
    this.auction,
    this.autobid,
    this.state,
    this.city,
    this.category,
    this.frontImage,
    this.backImage,
    this.interiorImage,
    this.engineImage,
    this.makeId,
    this.modelId,
    this.variantId,
    this.rank,
    this.watchlist,
    this.dealerMaxBid,
    this.userHighestPrice,
    this.userHasBid,
  });

  factory WatchlistVehicleItem.fromJson(Map<String, dynamic> json) =>
      WatchlistVehicleItem(
        vehicle:
            json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
        lender: json['lender'],
        vehicleInspection: json['vehicleInspection'],
        vehicleImages: json['vehicleImages'] != null
            ? VehicleImages.fromJson(json['vehicleImages'])
            : null,
        auction:
            json['auction'] != null ? Auction.fromJson(json['auction']) : null,
        autobid: json['autobid'],
        state: json['state']?.toString(),
        city: json['city']?.toString(),
        category: json['category']?.toString(),
        frontImage: json['frontImage']?.toString(),
        backImage: json['backImage']?.toString(),
        interiorImage: json['interiorImage']?.toString(),
        engineImage: json['engineImage']?.toString(),
        makeId: (json['makeId'] as num?)?.toInt(),
        modelId: (json['modelId'] as num?)?.toInt(),
        variantId: (json['variantId'] as num?)?.toInt(),
        rank: (json['rank'] as num?)?.toInt(),
        watchlist: json['watchlist'] as bool?,
        dealerMaxBid: (json['dealerMaxBid'] as num?)?.toDouble(),
        userHighestPrice: (json['userHighestPrice'] as num?)?.toDouble(),
        userHasBid: json['userHasBid'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'vehicle': vehicle?.toJson(),
        'lender': lender,
        'vehicleInspection': vehicleInspection,
        'vehicleImages': vehicleImages?.toJson(),
        'auction': auction?.toJson(),
        'autobid': autobid,
        'state': state,
        'city': city,
        'category': category,
        'frontImage': frontImage,
        'backImage': backImage,
        'interiorImage': interiorImage,
        'engineImage': engineImage,
        'makeId': makeId,
        'modelId': modelId,
        'variantId': variantId,
        'rank': rank,
        'watchlist': watchlist,
        'dealerMaxBid': dealerMaxBid,
        'userHighestPrice': userHighestPrice,
        'userHasBid': userHasBid,
      };
}

class Vehicle {
  final String? lotNo;
  final String? vehicleId;
  final String? loanNo;
  final bool? isRegistered;
  final String? auctionCalendarId;
  final String? mfgYear;
  final String? make;
  final String? model;
  final String? variant;
  final String? regno;
  final String? color;
  final String? rcStatus;
  final String? fuel;
  final String? location;
  final String? state;
  final String? city;
  final int? kmsDriven;
  final int? ownerCount;
  final String? transmissionType;
  final String? geerbox;
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
  final String? insuranceExpiryDate;
  final String? insuranceStatus;
  final double? startingPrice;
  final double? basePrice;
  final String? status;
  final String? saleOption;
  final int? auctionStartDate;
  final int? auctionEndDate;
  final int? userId;
  final int? winnerUserId;
  final double? winningBid;
  final String? winnerName;
  final int? lenderId;
  final String? userType;
  final String? displayFlag;
  final String? vehReport;
  final String? category;
  final String? area;
  final String? branch;
  final String? condition;
  final String? parkingYardName;
  final String? parkingYardAddress;
  final String? seizureDate;
  final String? approvalStatus;
  final String? mode;
  final String? metaAuctionId;
  final String? metaEventId;
  final String? region;
  final String? yardContactName;
  final String? yardContactNumber;
  final String? approvedAt;
  final String? source;
  final String? updatedAt;
  final String? createdDt;

  Vehicle({
    this.lotNo,
    this.vehicleId,
    this.loanNo,
    this.isRegistered,
    this.auctionCalendarId,
    this.mfgYear,
    this.make,
    this.model,
    this.variant,
    this.regno,
    this.color,
    this.rcStatus,
    this.fuel,
    this.location,
    this.state,
    this.city,
    this.kmsDriven,
    this.ownerCount,
    this.transmissionType,
    this.geerbox,
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
    this.insuranceExpiryDate,
    this.insuranceStatus,
    this.startingPrice,
    this.basePrice,
    this.status,
    this.saleOption,
    this.auctionStartDate,
    this.auctionEndDate,
    this.userId,
    this.winnerUserId,
    this.winningBid,
    this.winnerName,
    this.lenderId,
    this.userType,
    this.displayFlag,
    this.vehReport,
    this.category,
    this.area,
    this.branch,
    this.condition,
    this.parkingYardName,
    this.parkingYardAddress,
    this.seizureDate,
    this.approvalStatus,
    this.mode,
    this.metaAuctionId,
    this.metaEventId,
    this.region,
    this.yardContactName,
    this.yardContactNumber,
    this.approvedAt,
    this.source,
    this.updatedAt,
    this.createdDt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        lotNo: json['lotNo']?.toString(),
        vehicleId: json['vehicleId']?.toString(),
        loanNo: json['loanNo']?.toString(),
        isRegistered: json['isRegistered'] as bool?,
        auctionCalendarId: json['auctionCalendarId']?.toString(),
        mfgYear: json['mfgYear']?.toString(),
        make: json['make']?.toString(),
        model: json['model']?.toString(),
        variant: json['variant']?.toString(),
        regno: json['regno']?.toString(),
        color: json['color']?.toString(),
        rcStatus: json['rcStatus']?.toString(),
        fuel: json['fuel']?.toString(),
        location: json['location']?.toString(),
        state: json['state']?.toString(),
        city: json['city']?.toString(),
        kmsDriven: (json['kmsDriven'] as num?)?.toInt(),
        ownerCount: (json['ownerCount'] as num?)?.toInt(),
        transmissionType: json['transmissionType']?.toString(),
        geerbox: json['geerbox']?.toString(),
        roadtax: json['roadtax']?.toString(),
        hypothecation: json['hypothecation']?.toString(),
        hypothecationBank: json['hypothecationBank']?.toString(),
        duplicateKey: json['duplicateKey']?.toString(),
        chassisNo: json['chassisNo']?.toString(),
        engineNo: json['engineNo']?.toString(),
        pollutionForm: json['pollutionForm']?.toString(),
        rtoCode: json['rtoCode']?.toString(),
        rtoName: json['rtoName']?.toString(),
        fitnesReport: json['fitnesReport']?.toString(),
        insuranceExpiryDate: json['insuranceExpiryDate']?.toString(),
        insuranceStatus: json['insuranceStatus']?.toString(),
        startingPrice: (json['startingPrice'] as num?)?.toDouble(),
        basePrice: (json['basePrice'] as num?)?.toDouble(),
        status: json['status']?.toString(),
        saleOption: json['saleOption']?.toString(),
        auctionStartDate: (json['auctionStartDate'] as num?)?.toInt(),
        auctionEndDate: (json['auctionEndDate'] as num?)?.toInt(),
        userId: (json['userId'] as num?)?.toInt(),
        winnerUserId: (json['winnerUserId'] as num?)?.toInt(),
        winningBid: (json['winningBid'] as num?)?.toDouble(),
        winnerName: json['winnerName']?.toString(),
        lenderId: (json['lenderId'] as num?)?.toInt(),
        userType: json['userType']?.toString(),
        displayFlag: json['displayFlag']?.toString(),
        vehReport: json['vehReport']?.toString(),
        category: json['category']?.toString(),
        area: json['area']?.toString(),
        branch: json['branch']?.toString(),
        condition: json['condition']?.toString(),
        parkingYardName: json['parkingYardName']?.toString(),
        parkingYardAddress: json['parkingYardAddress']?.toString(),
        seizureDate: json['seizureDate']?.toString(),
        approvalStatus: json['approvalStatus']?.toString(),
        mode: json['mode']?.toString(),
        metaAuctionId: json['metaAuctionId']?.toString(),
        metaEventId: json['metaEventId']?.toString(),
        region: json['region']?.toString(),
        yardContactName: json['yardContactName']?.toString(),
        yardContactNumber: json['yardContactNumber']?.toString(),
        approvedAt: json['approvedAt']?.toString(),
        source: json['source']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
        createdDt: json['createdDt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'lotNo': lotNo,
        'vehicleId': vehicleId,
        'loanNo': loanNo,
        'isRegistered': isRegistered,
        'auctionCalendarId': auctionCalendarId,
        'mfgYear': mfgYear,
        'make': make,
        'model': model,
        'variant': variant,
        'regno': regno,
        'color': color,
        'rcStatus': rcStatus,
        'fuel': fuel,
        'location': location,
        'state': state,
        'city': city,
        'kmsDriven': kmsDriven,
        'ownerCount': ownerCount,
        'transmissionType': transmissionType,
        'geerbox': geerbox,
        'roadtax': roadtax,
        'hypothecation': hypothecation,
        'hypothecationBank': hypothecationBank,
        'duplicateKey': duplicateKey,
        'chassisNo': chassisNo,
        'engineNo': engineNo,
        'pollutionForm': pollutionForm,
        'rtoCode': rtoCode,
        'rtoName': rtoName,
        'fitnesReport': fitnesReport,
        'insuranceExpiryDate': insuranceExpiryDate,
        'insuranceStatus': insuranceStatus,
        'startingPrice': startingPrice,
        'basePrice': basePrice,
        'status': status,
        'saleOption': saleOption,
        'auctionStartDate': auctionStartDate,
        'auctionEndDate': auctionEndDate,
        'userId': userId,
        'winnerUserId': winnerUserId,
        'winningBid': winningBid,
        'winnerName': winnerName,
        'lenderId': lenderId,
        'userType': userType,
        'displayFlag': displayFlag,
        'vehReport': vehReport,
        'category': category,
        'area': area,
        'branch': branch,
        'condition': condition,
        'parkingYardName': parkingYardName,
        'parkingYardAddress': parkingYardAddress,
        'seizureDate': seizureDate,
        'approvalStatus': approvalStatus,
        'mode': mode,
        'metaAuctionId': metaAuctionId,
        'metaEventId': metaEventId,
        'region': region,
        'yardContactName': yardContactName,
        'yardContactNumber': yardContactNumber,
        'approvedAt': approvedAt,
        'source': source,
        'updatedAt': updatedAt,
        'createdDt': createdDt,
      };
}

class VehicleImages {
  final int? id;
  final String? vehicleId;
  final String? regno;
  final int? userId;
  final String? frontView;
  final String? frontLeftView;
  final String? rearView;
  final String? rearRightView;
  final String? rightFrontTyre;
  final String? rightRearTyre;
  final String? leftFrontTyre;
  final String? leftRearTyre;
  final String? interiorFrontView;
  final String? interiorBackView;
  final String? odometerView;
  final String? engineView;
  final String? chassisView;
  final String? chassisImprintView;
  final String? otherImage1;
  final String? otherImage2;
  final String? otherImage3;
  final String? otherImage4;
  final String? otherImage5;
  final String? createdDt;
  final String? updatedAt;
  final List<dynamic>? imagesAsList;
  final List<dynamic>? allImageUrls;

  VehicleImages({
    this.id,
    this.vehicleId,
    this.regno,
    this.userId,
    this.frontView,
    this.frontLeftView,
    this.rearView,
    this.rearRightView,
    this.rightFrontTyre,
    this.rightRearTyre,
    this.leftFrontTyre,
    this.leftRearTyre,
    this.interiorFrontView,
    this.interiorBackView,
    this.odometerView,
    this.engineView,
    this.chassisView,
    this.chassisImprintView,
    this.otherImage1,
    this.otherImage2,
    this.otherImage3,
    this.otherImage4,
    this.otherImage5,
    this.createdDt,
    this.updatedAt,
    this.imagesAsList,
    this.allImageUrls,
  });

  factory VehicleImages.fromJson(Map<String, dynamic> json) => VehicleImages(
        id: (json['id'] as num?)?.toInt(),
        vehicleId: json['vehicleId']?.toString(),
        regno: json['regno']?.toString(),
        userId: (json['userId'] as num?)?.toInt(),
        frontView: json['frontView']?.toString(),
        frontLeftView: json['frontLeftView']?.toString(),
        rearView: json['rearView']?.toString(),
        rearRightView: json['rearRightView']?.toString(),
        rightFrontTyre: json['rightFrontTyre']?.toString(),
        rightRearTyre: json['rightRearTyre']?.toString(),
        leftFrontTyre: json['leftFrontTyre']?.toString(),
        leftRearTyre: json['leftRearTyre']?.toString(),
        interiorFrontView: json['interiorFrontView']?.toString(),
        interiorBackView: json['interiorBackView']?.toString(),
        odometerView: json['odometerView']?.toString(),
        engineView: json['engineView']?.toString(),
        chassisView: json['chassisView']?.toString(),
        chassisImprintView: json['chassisImprintView']?.toString(),
        otherImage1: json['otherImage1']?.toString(),
        otherImage2: json['otherImage2']?.toString(),
        otherImage3: json['otherImage3']?.toString(),
        otherImage4: json['otherImage4']?.toString(),
        otherImage5: json['otherImage5']?.toString(),
        createdDt: json['createdDt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
        imagesAsList: json['imagesAsList'] as List<dynamic>?,
        allImageUrls: json['allImageUrls'] as List<dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'regno': regno,
        'userId': userId,
        'frontView': frontView,
        'frontLeftView': frontLeftView,
        'rearView': rearView,
        'rearRightView': rearRightView,
        'rightFrontTyre': rightFrontTyre,
        'rightRearTyre': rightRearTyre,
        'leftFrontTyre': leftFrontTyre,
        'leftRearTyre': leftRearTyre,
        'interiorFrontView': interiorFrontView,
        'interiorBackView': interiorBackView,
        'odometerView': odometerView,
        'engineView': engineView,
        'chassisView': chassisView,
        'chassisImprintView': chassisImprintView,
        'otherImage1': otherImage1,
        'otherImage2': otherImage2,
        'otherImage3': otherImage3,
        'otherImage4': otherImage4,
        'otherImage5': otherImage5,
        'createdDt': createdDt,
        'updatedAt': updatedAt,
        'imagesAsList': imagesAsList,
        'allImageUrls': allImageUrls,
      };
}

class Auction {
  final int? id;
  final String? auctionCalendarId;
  final String? eventId;
  final String? vehicleId;
  final String? regno;
  final String? loanNo;
  final int? lenderId;
  final double? startingPrice;
  final double? currentPrice;
  final double? basePrice;
  final int? startTime;
  final int? endTime;
  final int? extendedEndTime;
  final int? winnerUserId;
  final int? userId;
  final String? status;
  final int? extensionCount;
  final int? totalBids;
  final bool? reuploaded;
  final bool? cancelled;
  final bool? displayFlag;
  final String? mode;
  final String? cancelledBy;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;

  Auction({
    this.id,
    this.auctionCalendarId,
    this.eventId,
    this.vehicleId,
    this.regno,
    this.loanNo,
    this.lenderId,
    this.startingPrice,
    this.currentPrice,
    this.basePrice,
    this.startTime,
    this.endTime,
    this.extendedEndTime,
    this.winnerUserId,
    this.userId,
    this.status,
    this.extensionCount,
    this.totalBids,
    this.reuploaded,
    this.cancelled,
    this.displayFlag,
    this.mode,
    this.cancelledBy,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Auction.fromJson(Map<String, dynamic> json) => Auction(
        id: (json['id'] as num?)?.toInt(),
        auctionCalendarId: json['auctionCalendarId']?.toString(),
        eventId: json['eventId']?.toString(),
        vehicleId: json['vehicleId']?.toString(),
        regno: json['regno']?.toString(),
        loanNo: json['loanNo']?.toString(),
        lenderId: (json['lenderId'] as num?)?.toInt(),
        startingPrice: (json['startingPrice'] as num?)?.toDouble(),
        currentPrice: (json['currentPrice'] as num?)?.toDouble(),
        basePrice: (json['basePrice'] as num?)?.toDouble(),
        startTime: (json['startTime'] as num?)?.toInt(),
        endTime: (json['endTime'] as num?)?.toInt(),
        extendedEndTime: (json['extendedEndTime'] as num?)?.toInt(),
        winnerUserId: (json['winnerUserId'] as num?)?.toInt(),
        userId: (json['userId'] as num?)?.toInt(),
        status: json['status']?.toString(),
        extensionCount: (json['extensionCount'] as num?)?.toInt(),
        totalBids: (json['totalBids'] as num?)?.toInt(),
        reuploaded: json['reuploaded'] as bool?,
        cancelled: json['cancelled'] as bool?,
        displayFlag: json['displayFlag'] as bool?,
        mode: json['mode']?.toString(),
        cancelledBy: json['cancelledBy']?.toString(),
        cancelledAt: json['cancelledAt']?.toString(),
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'auctionCalendarId': auctionCalendarId,
        'eventId': eventId,
        'vehicleId': vehicleId,
        'regno': regno,
        'loanNo': loanNo,
        'lenderId': lenderId,
        'startingPrice': startingPrice,
        'currentPrice': currentPrice,
        'basePrice': basePrice,
        'startTime': startTime,
        'endTime': endTime,
        'extendedEndTime': extendedEndTime,
        'winnerUserId': winnerUserId,
        'userId': userId,
        'status': status,
        'extensionCount': extensionCount,
        'totalBids': totalBids,
        'reuploaded': reuploaded,
        'cancelled': cancelled,
        'displayFlag': displayFlag,
        'mode': mode,
        'cancelledBy': cancelledBy,
        'cancelledAt': cancelledAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
