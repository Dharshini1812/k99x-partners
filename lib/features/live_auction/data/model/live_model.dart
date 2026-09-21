/// The current dealer's own autobid record for a vehicle — returned as
/// the `"autobid"` field on the bid/view, bid/activity, and
/// live-vehicles-list endpoints. `null` when this dealer has never set
/// an autobid on that vehicle.
///
/// Sample payload (from `dealer/bid/autobid/{vehicleId}` context, as
/// echoed back by bid/view and events/live/.../vehicles):
/// {
///   "id": 12,
///   "maxBidAmount": 500000.0,
///   "userId": 126,
///   "vehicleId": "KL78155113251185322",
///   "active": true,
///   "updateAt": 1788506487871,
///   "createdAt": 1788506487871
/// }
///
/// `active == false` is how the backend tells us this dealer's autobid
/// can no longer raise the bid on their behalf — either because it was
/// pushed past [maxBidAmount] and the backend deactivated it, or it was
/// never turned on. Combined with the auction's current highest bid,
/// this is what drives disabling the "Autobid" button in PlaceBidSheet.
class AutobidInfo {
  final int? id;
  final double? maxBidAmount;
  final int? userId;
  final String? vehicleId;
  final bool? active;
  final int? updateAt;
  final int? createdAt;

  AutobidInfo({
    this.id,
    this.maxBidAmount,
    this.userId,
    this.vehicleId,
    this.active,
    this.updateAt,
    this.createdAt,
  });

  factory AutobidInfo.fromJson(Map<String, dynamic> json) {
    return AutobidInfo(
      id: json['id'],
      maxBidAmount: (json['maxBidAmount'] as num?)?.toDouble(),
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      active: json['active'],
      updateAt: json['updateAt'],
      createdAt: json['createdAt'],
    );
  }

  /// True once this autobid has been consumed — i.e. it was set up
  /// (has a [maxBidAmount]) but the backend no longer treats it as
  /// [active], typically because the running auction price reached or
  /// passed the ceiling the dealer approved. Also treats a still-active
  /// autobid whose ceiling the current bid has already met/exceeded as
  /// exhausted, in case an "active" flag update lags one poll behind.
  bool isExhausted(num? currentHighestBid) {
    if (maxBidAmount == null) return false;
    final reachedCeiling =
        currentHighestBid != null && currentHighestBid >= maxBidAmount!;
    if (active == false) return true;
    return reachedCeiling;
  }
}

class LiveAuctionModel {
  String? vehicleId;
  String? loanNo;
  String? mfgYear;
  String? make;
  String? model;
  String? variant;
  String? regno;
  String? fuel;
  int? kmsDriven;
  int? ownerCount;
  double? basePrice;
  String? status;
  String? auctionStartDt;
  String? auctionCloseDt;
  String? createdDt;
  String? updatedAt;
  double? winningBid;
  String? vehReport;
  int? lenderId;
  String? lenderName;
  int? categoryId;
  String? categoryName;
  String? stateName;
  String? cityName;
  List<BidsModel>? bids;
  VehicleImageModelF?
      imageUrl; // ADAPT: rename to match the actual JSON key once confirmed

  LiveAuctionModel(
      {this.vehicleId,
      this.loanNo,
      this.mfgYear,
      this.make,
      this.model,
      this.variant,
      this.regno,
      this.fuel,
      this.kmsDriven,
      this.ownerCount,
      this.basePrice,
      this.status,
      this.auctionStartDt,
      this.auctionCloseDt,
      this.createdDt,
      this.updatedAt,
      this.winningBid,
      this.vehReport,
      this.lenderId,
      this.lenderName,
      this.categoryId,
      this.categoryName,
      this.stateName,
      this.cityName,
      this.bids,
      this.imageUrl});

  LiveAuctionModel.fromJson(Map<String, dynamic> json) {
    vehicleId = json['vehicle_id'];
    loanNo = json['loan_no'];
    mfgYear = json['mfg_year'];
    make = json['make'];
    model = json['model'];
    variant = json['variant'];
    regno = json['regno'];
    fuel = json['fuel'];
    kmsDriven = json['kms_driven'];
    ownerCount = json['owner_count'];
    basePrice = json['base_price'];
    status = json['status'];
    auctionStartDt = json['auction_start_dt'];
    auctionCloseDt = json['auction_close_dt'];
    createdDt = json['created_dt'];
    updatedAt = json['updated_at'];
    winningBid = json['winning_bid'];
    vehReport = json['veh_report'];
    lenderId = json['lender_id'];
    lenderName = json['lender_name'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    stateName = json['state_name'];
    cityName = json['city_name'];
    if (json['front_view'] != null) {
      imageUrl = VehicleImageModelF.fromJson(json['front_view']);
    } // ADAPT: match actual key from real payload
    if (json['bids'] != null) {
      bids = <BidsModel>[];
      json['bids'].forEach((v) {
        bids!.add(BidsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicle_id'] = vehicleId;
    data['loan_no'] = loanNo;
    data['mfg_year'] = mfgYear;
    data['make'] = make;
    data['model'] = model;
    data['variant'] = variant;
    data['regno'] = regno;
    data['fuel'] = fuel;
    data['kms_driven'] = kmsDriven;
    data['owner_count'] = ownerCount;
    data['base_price'] = basePrice;
    data['status'] = status;
    data['auction_start_dt'] = auctionStartDt;
    data['auction_close_dt'] = auctionCloseDt;
    data['created_dt'] = createdDt;
    data['updated_at'] = updatedAt;
    data['winning_bid'] = winningBid;
    data['veh_report'] = vehReport;
    data['lender_id'] = lenderId;
    data['lender_name'] = lenderName;
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['state_name'] = stateName;
    data['city_name'] = cityName;
    data['front_view'] = imageUrl;
    // if (this.bids != null) {
    //   data['bids'] = this.bids!.map((v) => v.toJson()).toList();
    // }
    return data;
  }

  LiveAuctionModel copyWith({
    String? vehicleId,
    String? loanNo,
    String? mfgYear,
    String? make,
    String? model,
    String? variant,
    String? regno,
    String? fuel,
    int? kmsDriven,
    int? ownerCount,
    double? basePrice,
    String? status,
    String? auctionStartDt,
    String? auctionCloseDt,
    String? createdDt,
    String? updatedAt,
    double? winningBid,
    String? vehReport,
    int? lenderId,
    String? lenderName,
    int? categoryId,
    String? categoryName,
    String? stateName,
    String? cityName,
    List<BidsModel>? bids,
    String? imageUrl,
  }) {
    return LiveAuctionModel(
      vehicleId: vehicleId ?? this.vehicleId,
      loanNo: loanNo ?? this.loanNo,
      mfgYear: mfgYear ?? this.mfgYear,
      make: make ?? this.make,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      regno: regno ?? this.regno,
      fuel: fuel ?? this.fuel,
      kmsDriven: kmsDriven ?? this.kmsDriven,
      ownerCount: ownerCount ?? this.ownerCount,
      basePrice: basePrice ?? this.basePrice,
      status: status ?? this.status,
      auctionStartDt: auctionStartDt ?? this.auctionStartDt,
      auctionCloseDt: auctionCloseDt ?? this.auctionCloseDt,
      createdDt: createdDt ?? this.createdDt,
      updatedAt: updatedAt ?? this.updatedAt,
      winningBid: winningBid ?? this.winningBid,
      vehReport: vehReport ?? this.vehReport,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stateName: stateName ?? this.stateName,
      cityName: cityName ?? this.cityName,
      bids: bids ?? this.bids,
      imageUrl: this.imageUrl,
    );
  }
}

class BidsModel {
  int? id;
  double? amount;
  String? timestamp;
  int? auctionId;
  bool? isAutoBid;
  int? dealerId;
  String? vehicleId;
  String? bidderName;

  BidsModel(
      {this.id,
      this.amount,
      this.timestamp,
      this.auctionId,
      this.isAutoBid,
      this.dealerId,
      this.vehicleId,
      this.bidderName});

  BidsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    timestamp = json['timestamp'];
    auctionId = json['auction_id'];
    isAutoBid = json['is_auto_bid'];
    dealerId = json['dealer_id'];
    vehicleId = json['vehicle_id'];
    bidderName = json['bidder_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['timestamp'] = timestamp;
    data['auction_id'] = auctionId;
    data['is_auto_bid'] = isAutoBid;
    data['dealer_id'] = dealerId;
    data['vehicle_id'] = vehicleId;
    data['bidder_name'] = bidderName;
    return data;
  }
}

class VehicleImageModelF {
  String? fileName;
  String? label;
  String? type;
  String? url;
  String? publicId;

  VehicleImageModelF({
    this.fileName,
    this.label,
    this.type,
    this.url,
    this.publicId,
  });

  factory VehicleImageModelF.fromJson(Map<String, dynamic> json) {
    return VehicleImageModelF(
      fileName: json['fileName']?.toString(),
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      url: json['url']?.toString(),
      publicId: json['public_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'label': label,
      'type': type,
      'url': url,
      'public_id': publicId,
    };
  }
}
