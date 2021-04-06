class DepartmentsModel {
  int dEPID;
  String cDate;
  String uDate;
  String dDate;
  int hOSID;
  String name;
  int depApiId;
  int depWebId;
  String p1;
  String p2;
  String p3;
  int cancelled;

  DepartmentsModel({this.dEPID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.hOSID,
    this.name,
    this.depApiId,
    this.depWebId,
    this.p1,
    this.p2,
    this.p3,
    this.cancelled});

  DepartmentsModel.fromJson(Map<String, dynamic> json) {
    dEPID = json['DEP_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    hOSID = json['HOS_ID'];
    name = json['Name'];
    depApiId = json['dep_api_id'];
    depWebId = json['dep_web_id'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DEP_ID'] = this.dEPID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['HOS_ID'] = this.hOSID;
    data['Name'] = this.name;
    data['dep_api_id'] = this.depApiId;
    data['dep_web_id'] = this.depWebId;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['Cancelled'] = this.cancelled;
    return data;
  }
}
