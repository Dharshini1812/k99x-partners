class LenderModel {
  int? sno;
  Null lenderCode;
  Null scLenderBand;
  String? lenderName;
  String? lenderLogoUrl;

  LenderModel(
      {this.sno,
      this.lenderCode,
      this.scLenderBand,
      this.lenderName,
      this.lenderLogoUrl});

  LenderModel.fromJson(Map<String, dynamic> json) {
    sno = json['sno'];
    lenderCode = json['lenderCode'];
    scLenderBand = json['scLenderBand'];
    lenderName = json['lenderName'];
    lenderLogoUrl = json['lenderLogoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sno'] = sno;
    data['lenderCode'] = lenderCode;
    data['scLenderBand'] = scLenderBand;
    data['lenderName'] = lenderName;
    data['lenderLogoUrl'] = lenderLogoUrl;
    return data;
  }
}
