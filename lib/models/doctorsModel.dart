class DoctorsModel {
  int dOCID;
  String cDate;
  String uDate;
  String dDate;
  int dEPID;
  int hOSID;
  String title;
  String name;
  String photoPath;
  String info;
  int doktorApiId;
  String uzmanlik;
  String egitim;
  String iletisim;
  String sex;
  String p1;
  String p2;
  String p3;
  int cancelled;
  String kurumAdi;
  String kurumTuru;
  String brans;
  int depWebId;

  DoctorsModel({this.dOCID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.dEPID,
    this.hOSID,
    this.title,
    this.name,
    this.photoPath,
    this.info,
    this.doktorApiId,
    this.uzmanlik,
    this.egitim,
    this.iletisim,
    this.sex,
    this.p1,
    this.p2,
    this.p3,
    this.cancelled,
    this.kurumAdi,
    this.kurumTuru,
    this.brans,
    this.depWebId});

  DoctorsModel.fromJson(Map<String, dynamic> json) {
    dOCID = json['DOC_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    dEPID = json['DEP_ID'];
    hOSID = json['HOS_ID'];
    title = json['Title'];
    name = json['Name'];
    photoPath = json['Photo_Path'];
    info = json['Info'];
    doktorApiId = json['doktor_api_id'];
    uzmanlik = json['Uzmanlik'];
    egitim = json['Egitim'];
    iletisim = json['Iletisim'];
    sex = json['Sex'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    cancelled = json['Cancelled'];
    kurumAdi = json['Kurum_Adi'];
    kurumTuru = json['Kurum_Turu'];
    brans = json['Brans'];
    depWebId = json['dep_web_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DOC_ID'] = this.dOCID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['DEP_ID'] = this.dEPID;
    data['HOS_ID'] = this.hOSID;
    data['Title'] = this.title;
    data['Name'] = this.name;
    data['Photo_Path'] = this.photoPath;
    data['Info'] = this.info;
    data['doktor_api_id'] = this.doktorApiId;
    data['Uzmanlik'] = this.uzmanlik;
    data['Egitim'] = this.egitim;
    data['Iletisim'] = this.iletisim;
    data['Sex'] = this.sex;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['Cancelled'] = this.cancelled;
    data['Kurum_Adi'] = this.kurumAdi;
    data['Kurum_Turu'] = this.kurumTuru;
    data['Brans'] = this.brans;
    data['dep_web_id'] = this.depWebId;
    return data;
  }
}
