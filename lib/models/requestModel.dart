class RequestModel {
  int rEQUESTID;
  String cDate;
  String uDate;
  String dDate;
  int mEMID;
  int sPEID;
  String city;
  String requestDate;
  String lastStatus;
  String title;
  String message;
  String ay;
  int cancelled;

  RequestModel({this.rEQUESTID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.mEMID,
    this.sPEID,
    this.city,
    this.requestDate,
    this.lastStatus,
    this.title,
    this.message,
    this.ay,
    this.cancelled});

  RequestModel.fromJson(Map<String, dynamic> json) {
    rEQUESTID = json['REQUEST_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    mEMID = json['MEM_ID'];
    sPEID = json['SPE_ID'];
    city = json['City'];
    requestDate = json['Request_date'];
    lastStatus = json['LastStatus'];
    title = json['title'];
    message = json['message'];
    ay = json['Ay'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['REQUEST_ID'] = this.rEQUESTID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['MEM_ID'] = this.mEMID;
    data['SPE_ID'] = this.sPEID;
    data['City'] = this.city;
    data['Request_date'] = this.requestDate;
    data['LastStatus'] = this.lastStatus;
    data['title'] = this.title;
    data['message'] = this.message;
    data['Ay'] = this.ay;
    data['Cancelled'] = this.cancelled;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "REQUEST_ID": rEQUESTID,
      "CDate": cDate,
      "UDate": uDate,
      "DDate": dDate,
      "MEM_ID": mEMID,
      "SPE_ID": sPEID,
      "City": city,
      "Request_date": requestDate,
      "LastStatus": lastStatus,
      "Cancelled": cancelled,
    };
  }
}
