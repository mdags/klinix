import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ProgressDialog pr;
  final _formKey = GlobalKey<FormState>();
  final tcknController = new TextEditingController();
  final gsmController = new TextEditingController();

  Future<void> login() async {
    await pr.show();

    var res = await http.get(
      Variables.url +
          '/forgotPassword?tckn=' +
          tcknController.text +
          '&gsm=' +
          gsmController.text,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer ' + Variables.accessToken
      },
    );
    if (res.statusCode == 200) {
      var result = res.body.split('"').join('');
      if (result == "ok") {
        Navigator.of(context).pop();
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context).translate('error')),
            content: Text(result),
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
                  height: 60,
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
            controller: tcknController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('identity_number'),
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                counterText: '',
                errorStyle: TextStyle(
                  color: Colors.white,
                )),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context)
                    .translate('identity_number_error');
              } else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: gsmController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('register_gsm'),
              labelStyle: TextStyle(color: Colors.white),
              fillColor: Colors.white38,
              filled: true,
              counterText: '',
              errorStyle: TextStyle(
                color: Colors.white,
              ),
              prefix: Text(
                '+90',
                style: TextStyle(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context)
                    .translate('register_gsm_error');
              } else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context).translate('forgot_password_info'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
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
                AppLocalizations.of(context).translate('big_send'),
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  login();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
