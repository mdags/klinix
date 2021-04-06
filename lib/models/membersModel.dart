class MembersModel {
  int mEMID;
  String cDate;
  String uDate;
  String dDate;
  int mMEMID;
  String tCKN;
  String name;
  String bDate;
  String sex;
  String eMail;
  String gSM;
  String sMSCode;
  String passw;
  String sMSCodezaman;
  int teldogrulandi;
  String p1;
  String p2;
  String p3;
  int cancelled;

  MembersModel({this.mEMID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.mMEMID,
    this.tCKN,
    this.name,
    this.bDate,
    this.sex,
    this.eMail,
    this.gSM,
    this.sMSCode,
    this.passw,
    this.sMSCodezaman,
    this.teldogrulandi,
    this.p1,
    this.p2,
    this.p3,
    this.cancelled});

  MembersModel.fromJson(Map<String, dynamic> json) {
    mEMID = json['MEM_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    mMEMID = json['MMEM_ID'];
    tCKN = json['TCKN'];
    name = json['Name'];
    bDate = json['BDate'];
    sex = json['Sex'];
    eMail = json['EMail'];
    gSM = json['GSM'];
    sMSCode = json['SMSCode'];
    passw = json['Passw'];
    sMSCodezaman = json['SMSCodezaman'];
    teldogrulandi = json['teldogrulandi'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MEM_ID'] = this.mEMID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['MMEM_ID'] = this.mMEMID;
    data['TCKN'] = this.tCKN;
    data['Name'] = this.name;
    data['BDate'] = this.bDate;
    data['Sex'] = this.sex;
    data['EMail'] = this.eMail;
    data['GSM'] = this.gSM;
    data['SMSCode'] = this.sMSCode;
    data['Passw'] = this.passw;
    data['SMSCodezaman'] = this.sMSCodezaman;
    data['teldogrulandi'] = this.teldogrulandi;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['Cancelled'] = this.cancelled;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "MEM_ID": mEMID,
      "CDate": cDate,
      "UDate": uDate,
      "DDate": dDate,
      "MMEM_ID": mMEMID,
      "TCKN": tCKN,
      "Name": name,
      "BDate": bDate,
      "Sex": sex,
      "EMail": eMail,
      "GSM": gSM,
      "SMSCode": sMSCode,
      "Passw": passw,
      "SMSCodezaman": sMSCodezaman,
      "teldogrulandi": teldogrulandi,
      "P1": p1,
      "P2": p2,
      "P3": p3,
      "Cancelled": cancelled,
    };
  }
}

