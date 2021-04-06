import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:klinix/models/tokenModel.dart';

class Variables {
  static String tokenUrl = 'http://api.klinix.com.tr/token';
  static String url = 'http://api.klinix.com.tr/api/v1';
  static String tokenUser = 'ilerleyensa';
  static String tokenPass = 'IlrSa2020..';

  static String accessToken;

  static int memberId;
  static String tckn;
  static String gsm;
  static String adsoyad;
  static String email;
  static String sex;
  static String lang;

  static Color primaryColor = Color(0xFFf2293a);
  static Color greyColor = Color(0xFFF0EFEB);
  static Color secondaryColor = Color(0xFFc4020c);
  static Color thirdColor = Color(0xFF00a0e3);

  static final dateFormat = new DateFormat('dd.MM.yyyy');

  static String validateEmail(String value, String error) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return error;
    else
      return null;
  }

  static void getToken() async {
    var response = await http.post(
        Variables.tokenUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'grant_type': 'password',
          'username': Variables.tokenUser,
          'password': Variables.tokenPass
        }
    );
    if (response.statusCode == 200) {
      var result = TokenModel.fromJson(
          json.decode(response.body)
      );
      Variables.accessToken = result.accessToken;
    }
  }

}

enum Languages { tr, en, de, ar }

class Months {
  int id;
  String name;

  Months({ this.id, this.name });
}