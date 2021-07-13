// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) =>
    List<NotificationModel>.from(
        json.decode(str).map((x) => NotificationModel.fromJson(x)));

String notificationModelToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  NotificationModel({
    this.notificationId,
    this.cDate,
    this.uDate,
    this.dDate,
    this.message,
    this.memId,
    this.cancelled,
  });

  int notificationId;
  String cDate;
  String uDate;
  String dDate;
  String message;
  int memId;
  int cancelled;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationId: json["NOTIFICATION_ID"],
        cDate: json["CDate"],
        uDate: json["UDate"],
        dDate: json["DDate"],
        message: json["message"],
        memId: json["MEM_ID"],
        cancelled: json["Cancelled"],
      );

  Map<String, dynamic> toJson() => {
        "NOTIFICATION_ID": notificationId,
        "CDate": cDate,
        "UDate": uDate,
        "DDate": dDate,
        "message": message,
        "MEM_ID": memId,
        "Cancelled": cancelled,
      };
}
