import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  ProgressDialog pr;
  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = new TextEditingController();
  final newPasswordController = new TextEditingController();
  final rptPasswordController = new TextEditingController();

  Future<void> update() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getMemberById?id=' + Variables.memberId.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      List<MembersModel> _memberList =
          decodeList.map((i) => MembersModel.fromJson(i)).toList();
      if (_memberList.length > 0) {
        MembersModel member = _memberList[0];
        if (member.passw == oldPasswordController.text) {
          MembersModel member = new MembersModel(
            mEMID: Variables.memberId,
            passw: newPasswordController.text,
          );
          var body = json.encode(member.toMap());
          var res = await http.post(Variables.url + '/addMember',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'bearer ' + Variables.accessToken
              },
              body: body);
          if (res.statusCode == 200) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("password", newPasswordController.text);

            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(AppLocalizations.of(context).translate('error')),
                content: Text(
                    AppLocalizations.of(context).translate('password_changed')),
                actions: [
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context).translate('big_ok'),
                      style: TextStyle(color: Variables.primaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
            //Navigator.of(context).pop();
          }
        } else {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(AppLocalizations.of(context).translate('error')),
              content: Text(
                  AppLocalizations.of(context).translate('old_password_error')),
              actions: [
                TextButton(
                  child: Text(
                    AppLocalizations.of(context).translate('big_ok'),
                    style: TextStyle(color: Variables.primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
      }
    }

    await pr.hide();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(
        message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          padding: EdgeInsets.all(26.0),
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/sidemenu_background.png'),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/back_red.png',
                      color: Colors.white,
                      width: 24.0,
                      height: 24.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                    child: Image.asset('assets/images/logo_white.png'),
                    width: 200),
                SizedBox(
                  height: 30,
                ),
                formWidget(),
                Spacer(),
                Center(
                  child: InkWell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/tab_phone.png',
                          color: Colors.white,
                          width: 24.0,
                          height: 24.0,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          '0850 2 555 112',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    onTap: () => launch("tel:08502555112"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: oldPasswordController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            obscureText: true,
            decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('old_password'),
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                  color: Colors.white,
                )),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context)
                    .translate('old_password_error');
              } else if (value.length < 4) {
                return AppLocalizations.of(context)
                    .translate('password_min_error');
              } else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: newPasswordController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            obscureText: true,
            decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('new_password'),
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                  color: Colors.white,
                )),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context)
                    .translate('new_password_error');
              } else if (value.length < 4) {
                return AppLocalizations.of(context)
                    .translate('password_min_error');
              } else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: rptPasswordController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            obscureText: true,
            decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('repeat_password'),
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                  color: Colors.white,
                )),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context)
                    .translate('new_password_error');
              } else if (value != newPasswordController.text) {
                return AppLocalizations.of(context)
                    .translate('repeat_password_error');
              } else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.black12),
              child: Text(
                AppLocalizations.of(context).translate('change_password'),
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  update();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
