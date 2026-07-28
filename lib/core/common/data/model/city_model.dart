class CityModel {
  int? cityId;
  String? cityName;
  String? cityNameForecast;
  int? stateId;
  int? eqStateId;
  int? cityCat;
  int? hubId;
  String? hubActive;

  CityModel(
      {this.cityId,
      this.cityName,
      this.cityNameForecast,
      this.stateId,
      this.eqStateId,
      this.cityCat,
      this.hubId,
      this.hubActive});

  CityModel.fromJson(Map<String, dynamic> json) {
    cityId = json['cityId'];
    cityName = json['cityName'];
    cityNameForecast = json['cityNameForecast'];
    stateId = json['stateId'];
    eqStateId = json['eqStateId'];
    cityCat = json['cityCat'];
    hubId = json['hubId'];
    hubActive = json['hubActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cityId'] = cityId;
    data['cityName'] = cityName;
    data['cityNameForecast'] = cityNameForecast;
    data['stateId'] = stateId;
    data['eqStateId'] = eqStateId;
    data['cityCat'] = cityCat;
    data['hubId'] = hubId;
    data['hubActive'] = hubActive;
    return data;
  }
}
