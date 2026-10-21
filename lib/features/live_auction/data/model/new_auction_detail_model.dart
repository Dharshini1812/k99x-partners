// Dart models for "Event vehicles fetched successfully" response.
// Timestamps are epoch milliseconds (int). Prices are double.
// StateInfo / CityInfo are named to avoid clashing with Flutter's `State`.

double? _d(dynamic v) => (v as num?)?.toDouble();
int? _i(dynamic v) => (v as num?)?.toInt();

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) f) =>
    (v as List?)?.map((e) => f(e as Map<String, dynamic>)).toList() ?? [];

Map<String, dynamic>? _map(dynamic v) => v as Map<String, dynamic>?;

class EventVehiclesResponse {
  final EventVehiclesData? data;
  final bool success;
  final String? message;

  EventVehiclesResponse({this.data, this.success = false, this.message});

  factory EventVehiclesResponse.fromJson(Map<String, dynamic> json) =>
      EventVehiclesResponse(
        data: _map(json['data']) == null
            ? null
            : EventVehiclesData.fromJson(json['data']),
        success: json['success'] ?? false,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
        'success': success,
        'message': message,
      };
}

class EventVehiclesData {
  final bool hasMoreLiveVehicles;
  final List<VehicleItem> liveVehicles;
  final bool hasMoreClosedVehicles;
  final int? auctionStateId;
  final bool biddingAllowed;
  final List<VehicleItem> closedVehicles;

  EventVehiclesData({
    this.hasMoreLiveVehicles = false,
    this.liveVehicles = const [],
    this.hasMoreClosedVehicles = false,
    this.auctionStateId,
    this.biddingAllowed = false,
    this.closedVehicles = const [],
  });

  factory EventVehiclesData.fromJson(Map<String, dynamic> json) =>
      EventVehiclesData(
        hasMoreLiveVehicles: json['hasMoreLiveVehicles'] ?? false,
        liveVehicles: _list(json['liveVehicles'], VehicleItem.fromJson),
        hasMoreClosedVehicles: json['hasMoreClosedVehicles'] ?? false,
        auctionStateId: _i(json['auctionStateId']),
        biddingAllowed: json['biddingAllowed'] ?? false,
        closedVehicles: _list(json['closedVehicles'], VehicleItem.fromJson),
      );

  Map<String, dynamic> toJson() => {
        'hasMoreLiveVehicles': hasMoreLiveVehicles,
        'liveVehicles': liveVehicles.map((e) => e.toJson()).toList(),
        'hasMoreClosedVehicles': hasMoreClosedVehicles,
        'auctionStateId': auctionStateId,
        'biddingAllowed': biddingAllowed,
        'closedVehicles': closedVehicles.map((e) => e.toJson()).toList(),
      };
}

class VehicleItem {
  final Vehicle? vehicle;
  final Lender? lender;
  final String? lotNo;
  final dynamic vehicleInspection;
  final VehicleImages? vehicleImages;
  final Auction? auction;
  final AutoBid? autobid;
  final StateInfo? state;
  final CityInfo? city;
  final String? category;
  final String? frontImage;
  final String? backImage;
  final String? interiorImage;
  final String? engineImage;
  final int? makeId;
  final int? modelId;
  final int? variantId;
  final int rank;
  final bool watchlist;
  final double? dealerMaxBid;
  final double? userHighestPrice;
  final bool? userHasBid;
  final double? startingPrice;
  final double? basePrice;
  final String? status;

  VehicleItem({
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
    this.rank = 0,
    this.watchlist = false,
    this.dealerMaxBid,
    this.userHighestPrice,
    this.userHasBid,
    this.lotNo,
    this.startingPrice,
    this.basePrice,
    this.status,
  });

  factory VehicleItem.fromJson(Map<String, dynamic> json) => VehicleItem(
        vehicle: _map(json['vehicle']) == null
            ? null
            : Vehicle.fromJson(json['vehicle']),
        lender: _map(json['lender']) == null
            ? null
            : Lender.fromJson(json['lender']),
        vehicleInspection: json['vehicleInspection'],
        vehicleImages: _map(json['vehicleImages']) == null
            ? null
            : VehicleImages.fromJson(json['vehicleImages']),
        auction: _map(json['auction']) == null
            ? null
            : Auction.fromJson(json['auction']),
        autobid: _map(json['autobid']) == null
            ? null
            : AutoBid.fromJson(json['autobid']),
        state: _map(json['state']) == null
            ? null
            : StateInfo.fromJson(json['state']),
        city:
            _map(json['city']) == null ? null : CityInfo.fromJson(json['city']),
        category: json['category'],
        frontImage: json['frontImage'],
        backImage: json['backImage'],
        interiorImage: json['interiorImage'],
        engineImage: json['engineImage'],
        makeId: _i(json['makeId']),
        modelId: _i(json['modelId']),
        variantId: _i(json['variantId']),
        rank: _i(json['rank']) ?? 0,
        watchlist: json['watchlist'] ?? false,
        dealerMaxBid: _d(json['dealerMaxBid']),
        userHighestPrice: _d(json['userHighestPrice']),
        userHasBid: json['userHasBid'],
        lotNo: json['lotNo'],
        startingPrice: json['startingPrice'],
        basePrice: json['basePrice'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'vehicle': vehicle?.toJson(),
        'lender': lender?.toJson(),
        'vehicleInspection': vehicleInspection,
        'vehicleImages': vehicleImages?.toJson(),
        'auction': auction?.toJson(),
        'autobid': autobid?.toJson(),
        'state': state?.toJson(),
        'city': city?.toJson(),
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
  final int? insuranceExpiryDate;
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
  final bool? displayFlag;
  final String? vehReport;
  final String? category;
  final String? area;
  final String? branch;
  final String? condition;
  final String? parkingYardName;
  final String? parkingYardAddress;
  final int? seizureDate;
  final String? approvalStatus;
  final String? mode;
  final String? metaAuctionId;
  final String? metaEventId;
  final String? region;
  final String? yardContactName;
  final String? yardContactNumber;
  final int? approvedAt;
  final String? source;
  final int? updatedAt;
  final int? createdDt;

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

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        lotNo: j['lotNo'],
        vehicleId: j['vehicleId'],
        loanNo: j['loanNo'],
        isRegistered: j['isRegistered'],
        auctionCalendarId: j['auctionCalendarId'],
        mfgYear: j['mfgYear'],
        make: j['make'],
        model: j['model'],
        variant: j['variant'],
        regno: j['regno'],
        color: j['color'],
        rcStatus: j['rcStatus'],
        fuel: j['fuel'],
        location: j['location'],
        state: j['state'],
        city: j['city'],
        kmsDriven: _i(j['kmsDriven']),
        ownerCount: _i(j['ownerCount']),
        transmissionType: j['transmissionType'],
        geerbox: j['geerbox'],
        roadtax: j['roadtax'],
        hypothecation: j['hypothecation'],
        hypothecationBank: j['hypothecationBank'],
        duplicateKey: j['duplicateKey'],
        chassisNo: j['chassisNo'],
        engineNo: j['engineNo'],
        pollutionForm: j['pollutionForm'],
        rtoCode: j['rtoCode'],
        rtoName: j['rtoName'],
        fitnesReport: j['fitnesReport'],
        insuranceExpiryDate: _i(j['insuranceExpiryDate']),
        insuranceStatus: j['insuranceStatus'],
        startingPrice: _d(j['startingPrice']),
        basePrice: _d(j['basePrice']),
        status: j['status'],
        saleOption: j['saleOption'],
        auctionStartDate: _i(j['auctionStartDate']),
        auctionEndDate: _i(j['auctionEndDate']),
        userId: _i(j['userId']),
        winnerUserId: _i(j['winnerUserId']),
        winningBid: _d(j['winningBid']),
        winnerName: j['winnerName'],
        lenderId: _i(j['lenderId']),
        userType: j['userType'],
        displayFlag: j['displayFlag'],
        vehReport: j['vehReport'],
        category: j['category'],
        area: j['area'],
        branch: j['branch'],
        condition: j['condition'],
        parkingYardName: j['parkingYardName'],
        parkingYardAddress: j['parkingYardAddress'],
        seizureDate: _i(j['seizureDate']),
        approvalStatus: j['approvalStatus'],
        mode: j['mode'],
        metaAuctionId: j['metaAuctionId'],
        metaEventId: j['metaEventId'],
        region: j['region'],
        yardContactName: j['yardContactName'],
        yardContactNumber: j['yardContactNumber'],
        approvedAt: _i(j['approvedAt']),
        source: j['source'],
        updatedAt: _i(j['updatedAt']),
        createdDt: _i(j['createdDt']),
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

  DateTime? get auctionStart => auctionStartDate == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(auctionStartDate!);

  DateTime? get auctionEnd => auctionEndDate == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(auctionEndDate!);
}

class Lender {
  final int? sno;
  final String? lenderCode;
  final String? scLenderBand;
  final String? lenderName;
  final String? lenderLogoUrl;

  Lender({
    this.sno,
    this.lenderCode,
    this.scLenderBand,
    this.lenderName,
    this.lenderLogoUrl,
  });

  factory Lender.fromJson(Map<String, dynamic> j) => Lender(
        sno: _i(j['sno']),
        lenderCode: j['lenderCode'],
        scLenderBand: j['scLenderBand'],
        lenderName: j['lenderName'],
        lenderLogoUrl: j['lenderLogoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'sno': sno,
        'lenderCode': lenderCode,
        'scLenderBand': scLenderBand,
        'lenderName': lenderName,
        'lenderLogoUrl': lenderLogoUrl,
      };
}

class VehicleImages {
  final int? id;
  final String? vehicleId;
  final String? regno;
  final int? userId;
  final VehicleImageModelF? frontView;
  final VehicleImageModelF? frontLeftView;
  final VehicleImageModelF? rearView;
  final VehicleImageModelF? rearRightView;
  final VehicleImageModelF? rightFrontTyre;
  final VehicleImageModelF? rightRearTyre;
  final VehicleImageModelF? leftFrontTyre;
  final VehicleImageModelF? leftRearTyre;
  final VehicleImageModelF? interiorFrontView;
  final VehicleImageModelF? interiorBackView;
  final VehicleImageModelF? odometerView;
  final VehicleImageModelF? engineView;
  final VehicleImageModelF? chassisView;
  final VehicleImageModelF? chassisImprintView;
  final VehicleImageModelF? otherImage1;
  final VehicleImageModelF? otherImage2;
  final VehicleImageModelF? otherImage3;
  final VehicleImageModelF? otherImage4;
  final VehicleImageModelF? otherImage5;
  final int? createdDt;
  final int? updatedAt;
  final List<String> allImageUrls;
  final List<VehicleImageModelF> imagesAsList;

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
    this.allImageUrls = const [],
    this.imagesAsList = const [],
  });

  factory VehicleImages.fromJson(Map<String, dynamic> j) {
    VehicleImageModelF? parseImg(dynamic val) {
      if (val == null) return null;
      if (val is VehicleImageModelF) return val;
      if (val is Map<String, dynamic>) {
        return VehicleImageModelF.fromJson(val);
      }
      if (val is String && val.trim().isNotEmpty) {
        return VehicleImageModelF(url: val.trim());
      }
      return null;
    }

    dynamic getVal(String camel, String snake) => j[camel] ?? j[snake];

    return VehicleImages(
      id: _i(j['id']),
      vehicleId: j['vehicleId']?.toString() ?? j['vehicle_id']?.toString(),
      regno: j['regno']?.toString(),
      userId: _i(j['userId'] ?? j['user_id']),
      frontView: parseImg(getVal('frontView', 'front_view')),
      frontLeftView: parseImg(getVal('frontLeftView', 'front_left_view')),
      rearView: parseImg(getVal('rearView', 'rear_view')),
      rearRightView: parseImg(getVal('rearRightView', 'rear_right_view')),
      rightFrontTyre: parseImg(getVal('rightFrontTyre', 'right_front_tyre')),
      rightRearTyre: parseImg(getVal('rightRearTyre', 'right_rear_tyre')),
      leftFrontTyre: parseImg(getVal('leftFrontTyre', 'left_front_tyre')),
      leftRearTyre: parseImg(getVal('leftRearTyre', 'left_rear_tyre')),
      interiorFrontView:
          parseImg(getVal('interiorFrontView', 'interior_front_view')),
      interiorBackView:
          parseImg(getVal('interiorBackView', 'interior_back_view')),
      odometerView: parseImg(getVal('odometerView', 'odometer_view')),
      engineView: parseImg(getVal('engineView', 'engine_view')),
      chassisView: parseImg(getVal('chassisView', 'chassis_view')),
      chassisImprintView:
          parseImg(getVal('chassisImprintView', 'chassis_imprint_view')),
      otherImage1:
          parseImg(getVal('otherImage1', 'other_image1') ?? j['other_image_1']),
      otherImage2:
          parseImg(getVal('otherImage2', 'other_image2') ?? j['other_image_2']),
      otherImage3:
          parseImg(getVal('otherImage3', 'other_image3') ?? j['other_image_3']),
      otherImage4:
          parseImg(getVal('otherImage4', 'other_image4') ?? j['other_image_4']),
      otherImage5:
          parseImg(getVal('otherImage5', 'other_image5') ?? j['other_image_5']),
      createdDt: _i(j['createdDt'] ?? j['created_dt']),
      updatedAt: _i(j['updatedAt'] ?? j['updated_at']),
      allImageUrls:
          List<String>.from(j['allImageUrls'] ?? j['all_image_urls'] ?? []),
      imagesAsList: (j['imagesAsList'] ?? j['images_as_list'] as List?)
              ?.map((item) => parseImg(item))
              .whereType<VehicleImageModelF>()
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'regno': regno,
        'userId': userId,
        'frontView': frontView?.toJson(),
        'frontLeftView': frontLeftView?.toJson(),
        'rearView': rearView?.toJson(),
        'rearRightView': rearRightView?.toJson(),
        'rightFrontTyre': rightFrontTyre?.toJson(),
        'rightRearTyre': rightRearTyre?.toJson(),
        'leftFrontTyre': leftFrontTyre?.toJson(),
        'leftRearTyre': leftRearTyre?.toJson(),
        'interiorFrontView': interiorFrontView?.toJson(),
        'interiorBackView': interiorBackView?.toJson(),
        'odometerView': odometerView?.toJson(),
        'engineView': engineView?.toJson(),
        'chassisView': chassisView?.toJson(),
        'chassisImprintView': chassisImprintView?.toJson(),
        'otherImage1': otherImage1?.toJson(),
        'otherImage2': otherImage2?.toJson(),
        'otherImage3': otherImage3?.toJson(),
        'otherImage4': otherImage4?.toJson(),
        'otherImage5': otherImage5?.toJson(),
        'createdDt': createdDt,
        'updatedAt': updatedAt,
        'allImageUrls': allImageUrls,
        'imagesAsList': imagesAsList.map((e) => e.toJson()).toList(),
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
  final int extensionCount;
  final int totalBids;
  final bool reuploaded;
  final bool cancelled;
  final bool? displayFlag;
  final String? mode;
  final String? cancelledBy;
  final int? cancelledAt;
  final int? createdAt;
  final int? updatedAt;

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
    this.extensionCount = 0,
    this.totalBids = 0,
    this.reuploaded = false,
    this.cancelled = false,
    this.displayFlag,
    this.mode,
    this.cancelledBy,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Auction.fromJson(Map<String, dynamic> j) => Auction(
        id: _i(j['id']),
        auctionCalendarId: j['auctionCalendarId'],
        eventId: j['eventId'],
        vehicleId: j['vehicleId'],
        regno: j['regno'],
        loanNo: j['loanNo'],
        lenderId: _i(j['lenderId']),
        startingPrice: _d(j['startingPrice']),
        currentPrice: _d(j['currentPrice']),
        basePrice: _d(j['basePrice']),
        startTime: _i(j['startTime']),
        endTime: _i(j['endTime']),
        extendedEndTime: _i(j['extendedEndTime']),
        winnerUserId: _i(j['winnerUserId']),
        userId: _i(j['userId']),
        status: j['status'],
        extensionCount: _i(j['extensionCount']) ?? 0,
        totalBids: _i(j['totalBids']) ?? 0,
        reuploaded: j['reuploaded'] ?? false,
        cancelled: j['cancelled'] ?? false,
        displayFlag: j['displayFlag'],
        mode: j['mode'],
        cancelledBy: j['cancelledBy'],
        cancelledAt: _i(j['cancelledAt']),
        createdAt: _i(j['createdAt']),
        updatedAt: _i(j['updatedAt']),
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

  /// Effective end time: extended end time if present, else the normal one.
  DateTime? get effectiveEnd {
    final t = extendedEndTime ?? endTime;
    return t == null ? null : DateTime.fromMillisecondsSinceEpoch(t);
  }
}

class AutoBid {
  final int? id;
  final double? maxBidAmount;
  final int? userId;
  final String? vehicleId;
  final bool active;
  final int? updateAt;
  final int? createdAt;

  AutoBid({
    this.id,
    this.maxBidAmount,
    this.userId,
    this.vehicleId,
    this.active = false,
    this.updateAt,
    this.createdAt,
  });

  factory AutoBid.fromJson(Map<String, dynamic> j) => AutoBid(
        id: _i(j['id']),
        maxBidAmount: _d(j['maxBidAmount']),
        userId: _i(j['userId']),
        vehicleId: j['vehicleId'],
        active: j['active'] ?? false,
        updateAt: _i(j['updateAt']),
        createdAt: _i(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'maxBidAmount': maxBidAmount,
        'userId': userId,
        'vehicleId': vehicleId,
        'active': active,
        'updateAt': updateAt,
        'createdAt': createdAt,
      };
}

class StateInfo {
  final int? stateId;
  final String? stateName;
  final int? regionId;
  final bool? display;
  final int? eqStateId;
  final String? stateCode;
  final String? stateCapital;
  final String? gstCode;

  StateInfo({
    this.stateId,
    this.stateName,
    this.regionId,
    this.display,
    this.eqStateId,
    this.stateCode,
    this.stateCapital,
    this.gstCode,
  });

  factory StateInfo.fromJson(Map<String, dynamic> j) => StateInfo(
        stateId: _i(j['stateId']),
        stateName: j['stateName'],
        regionId: _i(j['regionId']),
        display: j['display'],
        eqStateId: _i(j['eqStateId']),
        stateCode: j['stateCode'],
        stateCapital: j['stateCapital'],
        gstCode: j['gstCode'],
      );

  Map<String, dynamic> toJson() => {
        'stateId': stateId,
        'stateName': stateName,
        'regionId': regionId,
        'display': display,
        'eqStateId': eqStateId,
        'stateCode': stateCode,
        'stateCapital': stateCapital,
        'gstCode': gstCode,
      };
}

class CityInfo {
  final int? cityId;
  final String? cityName;
  final String? cityNameForecast;
  final int? stateId;
  final int? eqStateId;
  final String? cityCat;
  final int? hubId;
  final bool? hubActive;

  CityInfo({
    this.cityId,
    this.cityName,
    this.cityNameForecast,
    this.stateId,
    this.eqStateId,
    this.cityCat,
    this.hubId,
    this.hubActive,
  });

  factory CityInfo.fromJson(Map<String, dynamic> j) => CityInfo(
        cityId: _i(j['cityId']),
        cityName: j['cityName'],
        cityNameForecast: j['cityNameForecast'],
        stateId: _i(j['stateId']),
        eqStateId: _i(j['eqStateId']),
        cityCat: j['cityCat'],
        hubId: _i(j['hubId']),
        hubActive: j['hubActive'],
      );

  Map<String, dynamic> toJson() => {
        'cityId': cityId,
        'cityName': cityName,
        'cityNameForecast': cityNameForecast,
        'stateId': stateId,
        'eqStateId': eqStateId,
        'cityCat': cityCat,
        'hubId': hubId,
        'hubActive': hubActive,
      };
}

class VehicleImageModelF {
  final String? fileName;
  final String? label;
  final String? type;
  final String? url;
  final String? publicId;

  VehicleImageModelF({
    this.fileName,
    this.label,
    this.type,
    this.url,
    this.publicId,
  });

  factory VehicleImageModelF.fromJson(dynamic v) {
    if (v is String) {
      return VehicleImageModelF(url: v);
    }
    if (v is Map<String, dynamic>) {
      return VehicleImageModelF(
        fileName: v['fileName']?.toString(),
        label: v['label']?.toString(),
        type: v['type']?.toString(),
        url: v['url']?.toString(),
        publicId: (v['public_id'] ?? v['publicId'])?.toString(),
      );
    }
    return VehicleImageModelF();
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'label': label,
        'type': type,
        'url': url,
        'public_id': publicId,
      };
}
