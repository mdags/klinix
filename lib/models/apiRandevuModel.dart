class ApiRandevuModel {
  String saat;
  int randevuID;
  String tarih;
  int siraNo;
  String servisAdi;
  String doktorAdi;

  ApiRandevuModel({this.saat,
    this.randevuID,
    this.tarih,
    this.siraNo,
    this.servisAdi,
    this.doktorAdi});

  ApiRandevuModel.fromJson(Map<String, dynamic> json) {
    saat = json['saat'];
    randevuID = json['RandevuID'];
    tarih = json['Tarih'];
    siraNo = json['SiraNo'];
    servisAdi = json['ServisAdi'];
    doktorAdi = json['DoktorAdi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['saat'] = this.saat;
    data['RandevuID'] = this.randevuID;
    data['Tarih'] = this.tarih;
    data['SiraNo'] = this.siraNo;
    data['ServisAdi'] = this.servisAdi;
    data['DoktorAdi'] = this.doktorAdi;
    return data;
  }
}
