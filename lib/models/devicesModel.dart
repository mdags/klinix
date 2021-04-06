class DevicesModel {
  int dEVID;
  String cDate;
  String uDate;
  String dDate;
  int mEMID;
  String cK;
  String dT;
  String dV;
  int cancelled;

  DevicesModel({this.dEVID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.mEMID,
    this.cK,
    this.dT,
    this.dV,
    this.cancelled});

  DevicesModel.fromJson(Map<String, dynamic> json) {
    dEVID = json['DEV_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    mEMID = json['MEM_ID'];
    cK = json['CK'];
    dT = json['DT'];
    dV = json['DV'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DEV_ID'] = this.dEVID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['MEM_ID'] = this.mEMID;
    data['CK'] = this.cK;
    data['DT'] = this.dT;
    data['DV'] = this.dV;
    data['Cancelled'] = this.cancelled;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "DEV_ID": dEVID,
      "CDate": cDate,
      "UDate": uDate,
      "DDate": dDate,
      "MEM_ID": mEMID,
      "CK": cK,
      "DT": dT,
      "DV": dV,
      "Cancelled": cancelled,
    };
  }
}
