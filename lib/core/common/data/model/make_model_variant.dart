class MakeModel {
  int? sno;
  String? name;
  int? catId;

  int? position;

  MakeModel({this.sno, this.name, this.catId, this.position});

  MakeModel.fromJson(Map<String, dynamic> json) {
    sno = json['sno'];
    name = json['name'];
    catId = json['catId'];

    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sno'] = sno;
    data['name'] = name;
    data['catId'] = catId;

    data['position'] = position;
    return data;
  }
}

class ModelModel {
  int? sno;
  String? name;

  ModelModel({this.sno, this.name});

  ModelModel.fromJson(Map<String, dynamic> json) {
    sno = json['sno'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sno'] = sno;
    data['name'] = name;
    return data;
  }
}

class VariantModel {
  int? sno;
  String? name;
  int? makeId;
  int? modelId;
  int? kmmvId;
  Null refId;
  int? catId;

  VariantModel(
      {this.sno,
      this.name,
      this.makeId,
      this.modelId,
      this.kmmvId,
      this.refId,
      this.catId});

  VariantModel.fromJson(Map<String, dynamic> json) {
    sno = json['sno'];
    name = json['name'];
    makeId = json['makeId'];
    modelId = json['modelId'];
    kmmvId = json['kmmvId'];
    refId = json['refId'];
    catId = json['catId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sno'] = sno;
    data['name'] = name;
    data['makeId'] = makeId;
    data['modelId'] = modelId;
    data['kmmvId'] = kmmvId;
    data['refId'] = refId;
    data['catId'] = catId;
    return data;
  }
}
