class FavoritesModel {
  int fAVID;
  String cDate;
  Null uDate;
  Null dDate;
  int favtur;
  int favkurumid;
  int favdokid;
  int favuyeid;
  String hastaneisim;
  String sehir;
  String doktorisim;
  String title;
  String doktorkurum;
  String doktorbolum;

  FavoritesModel({this.fAVID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.favtur,
    this.favkurumid,
    this.favdokid,
    this.favuyeid,
    this.hastaneisim,
    this.sehir,
    this.doktorisim,
    this.title,
    this.doktorkurum,
    this.doktorbolum});

  FavoritesModel.fromJson(Map<String, dynamic> json) {
    fAVID = json['FAV_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    favtur = json['favtur'];
    favkurumid = json['favkurumid'];
    favdokid = json['favdokid'];
    favuyeid = json['favuyeid'];
    hastaneisim = json['hastaneisim'];
    sehir = json['sehir'];
    doktorisim = json['doktorisim'];
    doktorkurum = json['doktorkurum'];
    doktorbolum = json['doktorbolum'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FAV_ID'] = this.fAVID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['favtur'] = this.favtur;
    data['favkurumid'] = this.favkurumid;
    data['favdokid'] = this.favdokid;
    data['favuyeid'] = this.favuyeid;
    data['hastaneisim'] = this.hastaneisim;
    data['sehir'] = this.sehir;
    data['doktorisim'] = this.doktorisim;
    data['title'] = this.title;
    data['doktorkurum'] = this.doktorkurum;
    data['doktorbolum'] = this.doktorbolum;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "FAV_ID": fAVID,
      "CDate": cDate,
      "UDate": uDate,
      "DDate": dDate,
      "favtur": favtur,
      "favkurumid": favkurumid,
      "favdokid": favdokid,
      "favuyeid": favuyeid,
      "hastaneisim": hastaneisim,
      "sehir": sehir,
      "doktorisim": doktorisim,
      "title": title,
      "doktorkurum": doktorkurum,
      "doktorbolum": doktorbolum
    };
  }
}
