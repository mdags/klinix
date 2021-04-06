class HospitalsModel {
  int hOSID;
  String cDate;
  String uDate;
  String dDate;
  String firmaKodu;
  String category;
  String name;
  String logoPath;
  String info;
  String cPersonName;
  String cPersonEmail;
  String cPersonGSM;
  String uRL;
  String tLF1;
  String tLF2;
  int apikullanimi;
  int apiId;
  String konum;
  String sehir;
  String ilce;
  double indirim;
  double indirimsozlesme;
  String adres;
  String anlasmavarmi;
  String p1;
  String p2;
  String p3;
  int cancelled;

  HospitalsModel({this.hOSID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.firmaKodu,
    this.category,
    this.name,
    this.logoPath,
    this.info,
    this.cPersonName,
    this.cPersonEmail,
    this.cPersonGSM,
    this.uRL,
    this.tLF1,
    this.tLF2,
    this.apikullanimi,
    this.apiId,
    this.konum,
    this.sehir,
    this.ilce,
    this.indirim,
    this.indirimsozlesme,
    this.adres,
    this.anlasmavarmi,
    this.p1,
    this.p2,
    this.p3,
    this.cancelled});

  HospitalsModel.fromJson(Map<String, dynamic> json) {
    hOSID = json['HOS_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    firmaKodu = json['FirmaKodu'];
    category = json['Category'];
    name = json['Name'];
    logoPath = json['Logo_Path'];
    info = json['Info'];
    cPersonName = json['CPersonName'];
    cPersonEmail = json['CPersonEmail'];
    cPersonGSM = json['CPersonGSM'];
    uRL = json['URL'];
    tLF1 = json['TLF1'];
    tLF2 = json['TLF2'];
    apikullanimi = json['apikullanimi'];
    apiId = json['api_id'];
    konum = json['konum'];
    sehir = json['sehir'];
    ilce = json['ilce'];
    indirim = json['indirim'];
    indirimsozlesme = json['indirimsozlesme'];
    adres = json['adres'];
    anlasmavarmi = json['anlasmavarmi'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['HOS_ID'] = this.hOSID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['FirmaKodu'] = this.firmaKodu;
    data['Category'] = this.category;
    data['Name'] = this.name;
    data['Logo_Path'] = this.logoPath;
    data['Info'] = this.info;
    data['CPersonName'] = this.cPersonName;
    data['CPersonEmail'] = this.cPersonEmail;
    data['CPersonGSM'] = this.cPersonGSM;
    data['URL'] = this.uRL;
    data['TLF1'] = this.tLF1;
    data['TLF2'] = this.tLF2;
    data['apikullanimi'] = this.apikullanimi;
    data['api_id'] = this.apiId;
    data['konum'] = this.konum;
    data['sehir'] = this.sehir;
    data['ilce'] = this.ilce;
    data['indirim'] = this.indirim;
    data['indirimsozlesme'] = this.indirimsozlesme;
    data['adres'] = this.adres;
    data['anlasmavarmi'] = this.anlasmavarmi;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['Cancelled'] = this.cancelled;
    return data;
  }
}
