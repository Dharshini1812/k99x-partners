class StateModel {
  int? stateId;
  String? stateName;
  int? regionId;
  String? display;
  int? eqStateId;
  String? stateCode;
  String? stateCapital;
  int? gstCode;

  StateModel(
      {this.stateId,
      this.stateName,
      this.regionId,
      this.display,
      this.eqStateId,
      this.stateCode,
      this.stateCapital,
      this.gstCode});

  StateModel.fromJson(Map<String, dynamic> json) {
    stateId = json['stateId'];
    stateName = json['stateName'];
    regionId = json['regionId'];
    display = json['display'];
    eqStateId = json['eqStateId'];
    stateCode = json['stateCode'];
    stateCapital = json['stateCapital'];
    gstCode = json['gstCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stateId'] = stateId;
    data['stateName'] = stateName;
    data['regionId'] = regionId;
    data['display'] = display;
    data['eqStateId'] = eqStateId;
    data['stateCode'] = stateCode;
    data['stateCapital'] = stateCapital;
    data['gstCode'] = gstCode;
    return data;
  }
}
