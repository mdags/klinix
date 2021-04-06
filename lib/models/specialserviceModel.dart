class SpecialserviceModel {
  int sPEID;
  String cDate;
  String uDate;
  String dDate;
  String title;
  String images;
  int imagesid;
  String message;
  String language;
  int sSPEID;
  int ranking;
  int cancelled;

  SpecialserviceModel(
      {this.sPEID,
        this.cDate,
        this.uDate,
        this.dDate,
        this.title,
        this.images,
        this.imagesid,
        this.message,
        this.language,
        this.sSPEID,
        this.ranking,
        this.cancelled});

  SpecialserviceModel.fromJson(Map<String, dynamic> json) {
    sPEID = json['SPE_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    title = json['title'];
    images = json['images'];
    imagesid = json['imagesid'];
    message = json['message'];
    language = json['language'];
    sSPEID = json['SSPE_ID'];
    ranking = json['ranking'];
    cancelled = json['Cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SPE_ID'] = this.sPEID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['title'] = this.title;
    data['images'] = this.images;
    data['imagesid'] = this.imagesid;
    data['message'] = this.message;
    data['language'] = this.language;
    data['SSPE_ID'] = this.sSPEID;
    data['ranking'] = this.ranking;
    data['Cancelled'] = this.cancelled;
    return data;
  }
}
