class CityModel {
  int cITYID;
  String cDate;
  String uDate;
  String dDate;
  String cityName;
  int cancelled;

  CityModel(
      {this.cITYID,
        this.cDate,
        this.uDate,
        this.dDate,
        this.cityName,
        this.cancelled});

  CityModel.fromJson(Map<String, dynamic> json) {
    cITYID = json['CITY_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    cityName = json['City_name'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CITY_ID'] = this.cITYID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['City_name'] = this.cityName;
    data['Cancelled'] = this.cancelled;
    return data;
  }
}
