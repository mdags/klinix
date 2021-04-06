class PharmaciesModel {
  int pHAID;
  String cDate;
  String uDate;
  String dDate;
  String nDate;
  String name;
  String address;
  String city;
  String town;
  String gPS;
  String tLF;
  String p1;
  String p2;
  String p3;
  int cancelled;

  PharmaciesModel(
      {this.pHAID,
        this.cDate,
        this.uDate,
        this.dDate,
        this.nDate,
        this.name,
        this.address,
        this.city,
        this.town,
        this.gPS,
        this.tLF,
        this.p1,
        this.p2,
        this.p3,
        this.cancelled});

  PharmaciesModel.fromJson(Map<String, dynamic> json) {
    pHAID = json['PHA_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    nDate = json['NDate'];
    name = json['Name'];
    address = json['Address'];
    city = json['City'];
    town = json['Town'];
    gPS = json['GPS'];
    tLF = json['TLF'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PHA_ID'] = this.pHAID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['NDate'] = this.nDate;
    data['Name'] = this.name;
    data['Address'] = this.address;
    data['City'] = this.city;
    data['Town'] = this.town;
    data['GPS'] = this.gPS;
    data['TLF'] = this.tLF;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['Cancelled'] = this.cancelled;
    return data;
  }
}
