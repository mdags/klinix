// To parse this JSON data, do
//
//     final announcementModel = announcementModelFromJson(jsonString);

import 'dart:convert';

List<AnnouncementModel> announcementModelFromJson(String str) =>
    List<AnnouncementModel>.from(
        json.decode(str).map((x) => AnnouncementModel.fromJson(x)));

String announcementModelToJson(List<AnnouncementModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AnnouncementModel {
  AnnouncementModel({
    this.annoId,
    this.cDate,
    this.uDate,
    this.dDate,
    this.message,
    this.cancelled,
  });

  int annoId;
  String cDate;
  String uDate;
  String dDate;
  String message;
  int cancelled;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        annoId: json["ANNO_ID"],
        cDate: json["CDate"],
        uDate: json["UDate"],
        dDate: json["DDate"],
        message: json["message"],
        cancelled: json["Cancelled"],
      );

  Map<String, dynamic> toJson() => {
        "ANNO_ID": annoId,
        "CDate": cDate,
        "UDate": uDate,
        "DDate": dDate,
        "message": message,
        "Cancelled": cancelled,
      };
}
