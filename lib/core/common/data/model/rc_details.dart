class RCDetailsModel {
  String? id;
  String? requestId;
  String? registrationNumber;
  String? chassisNumber;
  String? engineNumber;
  String? ownerName;
  String? fatherName;
  int? ownerSerialNumber;
  String? permanentAddress;
  String? presentAddress;
  String? vehicleCategory;
  String? vehicleClassDescription;
  String? bodyTypeDescription;
  String? makerDescription;
  String? makerModel;
  String? color;
  String? fuelDescription;
  int? seatingCapacity;
  int? sleeperCapacity;
  int? standingCapacity;
  int? numberOfCylinders;
  double? cubicCapacity;
  int? grossVehicleWeight;
  int? unladenWeight;
  int? wheelbase;
  String? registrationDate;
  String? manufacturedMonthYear;
  String? taxPaidUpto;
  String? fitnessUpto;
  String? insuranceCompany;
  String? insurancePolicyNumber;
  String? insuranceUpto;
  String? pucNumber;
  String? pucExpiryDate;
  String? registeredAt;
  String? rcStatus;
  String? rcMobileNo;
  String? financier;
  String? normsDescription;
  String? blackListStatus;
  List<Null>? blackListInfo;
  String? nocDetails;
  String? nonUseFrom;
  String? nonUseTo;
  String? rcNonUseStatus;
  String? nationalPermitNumber;
  String? nationalPermitIssuedBy;
  String? nationalPermitExpiryDate;
  String? statePermitNumber;
  String? statePermitType;
  String? statePermitIssuedDate;
  String? statePermitExpiryDate;
  String? stateCd;
  String? statusAsOn;
  String? statusMessage;
  int? statusCode;
  String? sourceType;
  int? createdAt;
  int? updatedAt;

  RCDetailsModel(
      {this.id,
      this.requestId,
      this.registrationNumber,
      this.chassisNumber,
      this.engineNumber,
      this.ownerName,
      this.fatherName,
      this.ownerSerialNumber,
      this.permanentAddress,
      this.presentAddress,
      this.vehicleCategory,
      this.vehicleClassDescription,
      this.bodyTypeDescription,
      this.makerDescription,
      this.makerModel,
      this.color,
      this.fuelDescription,
      this.seatingCapacity,
      this.sleeperCapacity,
      this.standingCapacity,
      this.numberOfCylinders,
      this.cubicCapacity,
      this.grossVehicleWeight,
      this.unladenWeight,
      this.wheelbase,
      this.registrationDate,
      this.manufacturedMonthYear,
      this.taxPaidUpto,
      this.fitnessUpto,
      this.insuranceCompany,
      this.insurancePolicyNumber,
      this.insuranceUpto,
      this.pucNumber,
      this.pucExpiryDate,
      this.registeredAt,
      this.rcStatus,
      this.rcMobileNo,
      this.financier,
      this.normsDescription,
      this.blackListStatus,
      this.blackListInfo,
      this.nocDetails,
      this.nonUseFrom,
      this.nonUseTo,
      this.rcNonUseStatus,
      this.nationalPermitNumber,
      this.nationalPermitIssuedBy,
      this.nationalPermitExpiryDate,
      this.statePermitNumber,
      this.statePermitType,
      this.statePermitIssuedDate,
      this.statePermitExpiryDate,
      this.stateCd,
      this.statusAsOn,
      this.statusMessage,
      this.statusCode,
      this.sourceType,
      this.createdAt,
      this.updatedAt});

  RCDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestId = json['requestId'];
    registrationNumber = json['registrationNumber'];
    chassisNumber = json['chassisNumber'];
    engineNumber = json['engineNumber'];
    ownerName = json['ownerName'];
    fatherName = json['fatherName'];
    ownerSerialNumber = json['ownerSerialNumber'];
    permanentAddress = json['permanentAddress'];
    presentAddress = json['presentAddress'];
    vehicleCategory = json['vehicleCategory'];
    vehicleClassDescription = json['vehicleClassDescription'];
    bodyTypeDescription = json['bodyTypeDescription'];
    makerDescription = json['makerDescription'];
    makerModel = json['makerModel'];
    color = json['color'];
    fuelDescription = json['fuelDescription'];
    seatingCapacity = json['seatingCapacity'];
    sleeperCapacity = json['sleeperCapacity'];
    standingCapacity = json['standingCapacity'];
    numberOfCylinders = json['numberOfCylinders'];
    cubicCapacity = json['cubicCapacity'];
    grossVehicleWeight = json['grossVehicleWeight'];
    unladenWeight = json['unladenWeight'];
    wheelbase = json['wheelbase'];
    registrationDate = json['registrationDate'];
    manufacturedMonthYear = json['manufacturedMonthYear'];
    taxPaidUpto = json['taxPaidUpto'];
    fitnessUpto = json['fitnessUpto'];
    insuranceCompany = json['insuranceCompany'];
    insurancePolicyNumber = json['insurancePolicyNumber'];
    insuranceUpto = json['insuranceUpto'];
    pucNumber = json['pucNumber'];
    pucExpiryDate = json['pucExpiryDate'];
    registeredAt = json['registeredAt'];
    rcStatus = json['rcStatus'];
    rcMobileNo = json['rcMobileNo'];
    financier = json['financier'];
    normsDescription = json['normsDescription'];
    blackListStatus = json['blackListStatus'];
    if (json['blackListInfo'] != null) {
      blackListInfo = <Null>[];
      json['blackListInfo'].forEach((v) {});
    }
    nocDetails = json['nocDetails'];
    nonUseFrom = json['nonUseFrom'];
    nonUseTo = json['nonUseTo'];
    rcNonUseStatus = json['rcNonUseStatus'];
    nationalPermitNumber = json['nationalPermitNumber'];
    nationalPermitIssuedBy = json['nationalPermitIssuedBy'];
    nationalPermitExpiryDate = json['nationalPermitExpiryDate'];
    statePermitNumber = json['statePermitNumber'];
    statePermitType = json['statePermitType'];
    statePermitIssuedDate = json['statePermitIssuedDate'];
    statePermitExpiryDate = json['statePermitExpiryDate'];
    stateCd = json['stateCd'];
    statusAsOn = json['statusAsOn'];
    statusMessage = json['statusMessage'];
    statusCode = json['statusCode'];
    sourceType = json['sourceType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['requestId'] = requestId;
    data['registrationNumber'] = registrationNumber;
    data['chassisNumber'] = chassisNumber;
    data['engineNumber'] = engineNumber;
    data['ownerName'] = ownerName;
    data['fatherName'] = fatherName;
    data['ownerSerialNumber'] = ownerSerialNumber;
    data['permanentAddress'] = permanentAddress;
    data['presentAddress'] = presentAddress;
    data['vehicleCategory'] = vehicleCategory;
    data['vehicleClassDescription'] = vehicleClassDescription;
    data['bodyTypeDescription'] = bodyTypeDescription;
    data['makerDescription'] = makerDescription;
    data['makerModel'] = makerModel;
    data['color'] = color;
    data['fuelDescription'] = fuelDescription;
    data['seatingCapacity'] = seatingCapacity;
    data['sleeperCapacity'] = sleeperCapacity;
    data['standingCapacity'] = standingCapacity;
    data['numberOfCylinders'] = numberOfCylinders;
    data['cubicCapacity'] = cubicCapacity;
    data['grossVehicleWeight'] = grossVehicleWeight;
    data['unladenWeight'] = unladenWeight;
    data['wheelbase'] = wheelbase;
    data['registrationDate'] = registrationDate;
    data['manufacturedMonthYear'] = manufacturedMonthYear;
    data['taxPaidUpto'] = taxPaidUpto;
    data['fitnessUpto'] = fitnessUpto;
    data['insuranceCompany'] = insuranceCompany;
    data['insurancePolicyNumber'] = insurancePolicyNumber;
    data['insuranceUpto'] = insuranceUpto;
    data['pucNumber'] = pucNumber;
    data['pucExpiryDate'] = pucExpiryDate;
    data['registeredAt'] = registeredAt;
    data['rcStatus'] = rcStatus;
    data['rcMobileNo'] = rcMobileNo;
    data['financier'] = financier;
    data['normsDescription'] = normsDescription;
    data['blackListStatus'] = blackListStatus;

    data['nocDetails'] = nocDetails;
    data['nonUseFrom'] = nonUseFrom;
    data['nonUseTo'] = nonUseTo;
    data['rcNonUseStatus'] = rcNonUseStatus;
    data['nationalPermitNumber'] = nationalPermitNumber;
    data['nationalPermitIssuedBy'] = nationalPermitIssuedBy;
    data['nationalPermitExpiryDate'] = nationalPermitExpiryDate;
    data['statePermitNumber'] = statePermitNumber;
    data['statePermitType'] = statePermitType;
    data['statePermitIssuedDate'] = statePermitIssuedDate;
    data['statePermitExpiryDate'] = statePermitExpiryDate;
    data['stateCd'] = stateCd;
    data['statusAsOn'] = statusAsOn;
    data['statusMessage'] = statusMessage;
    data['statusCode'] = statusCode;
    data['sourceType'] = sourceType;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
