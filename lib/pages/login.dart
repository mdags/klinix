import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:klinix/models/devicesModel.dart';
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/pages/appointments.dart';
import 'package:klinix/pages/favorites.dart';
import 'package:klinix/pages/forgot_password.dart';
import 'package:klinix/pages/profile.dart';
import 'package:klinix/pages/register.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final String destination;
  final int initialIndex;
  final HospitalsModel hospital;
  final DoctorsModel doctor;

  LoginPage({ this.destination, this.initialIndex, this.hospital, this.doctor });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ProgressDialog pr;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _formKey = GlobalKey<FormState>();
  final usernameController = new TextEditingController();
  final passwordController = new TextEditingController();

  Future<void> getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    usernameController.text = prefs.get("username") ?? '';
    passwordController.text = prefs.get("password") ?? '';
  }

  Future<void> login() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/memberLogin?username=' + usernameController.text +
            '&password=' + passwordController.text,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      List<MembersModel> memberList = decodeList.map((i) =>
          MembersModel.fromJson(i)).toList();

      if (memberList.length > 0) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("username", usernameController.text);
        prefs.setString("password", passwordController.text);

        Variables.memberId = memberList[0].mEMID;
        Variables.tckn = memberList[0].tCKN;
        Variables.gsm = memberList[0].gSM;
        Variables.adsoyad = memberList[0].name;
        Variables.email = memberList[0].eMail;
        Variables.sex = memberList[0].sex;

        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        String ck, dt, dv;
        if (Platform.isAndroid) {
          AndroidDeviceInfo android = await deviceInfoPlugin.androidInfo;
          ck = android.androidId.substring(0, 6);
          dt = 'android';
        } else if (Platform.isIOS) {
          IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
          ck = ios.identifierForVendor.substring(0, 6);
          dt = 'ios';
        }
        _firebaseMessaging.configure(
          onLaunch: (Map<String, dynamic> message) {
            print('onLaunch called');
          },
          onResume: (Map<String, dynamic> message) {
            print('onResume called');
          },
          onMessage: (Map<String, dynamic> message) {
            print('onMessage called');
          },
        );
        _firebaseMessaging.subscribeToTopic('all');
        _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
          sound: true,
          badge: true,
          alert: true,
        ));
        _firebaseMessaging.onIosSettingsRegistered
            .listen((IosNotificationSettings settings) {
          print('token registered');
        });
        _firebaseMessaging.getToken().then((token) async {
          dv = token;
          print('token:' + token);
          DevicesModel device = new DevicesModel(
              mEMID: memberList[0].mEMID,
              cK: ck,
              dT: dt,
              dV: dv
          );
          var body = json.encode(device.toMap());
          res = await http.post(
              Variables.url + '/addDevice',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'bearer ' + Variables.accessToken
              },
              body: body);
          if (res.statusCode == 200){

          }
        });

        DevicesModel device = new DevicesModel(
            mEMID: memberList[0].mEMID,
            cK: ck,
            dT: dt,
            dV: dv
        );
        var body = json.encode(device.toMap());
        res = await http.post(
            Variables.url + '/addDevice',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
            body: body);
        if (res.statusCode == 200){

        }

        await pr.hide();

        if (widget.destination != null) {
          if (widget.destination == 'appointment') {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) => AppointmentsPage(
                      hospital: widget.hospital,
                      doctor: widget.doctor,
                    ),
                ));
          }
          if (widget.destination == 'profile') {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) => ProfilePage()
                ));
          }
          if (widget.destination == 'favorite') {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) => FavoritesPage(
                      initialIndex: widget.initialIndex,
                    )
                ));
          }
        }
      }
      else {
        await pr.hide();
        showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text(AppLocalizations.of(context).translate('error')),
                content: Text(
                    AppLocalizations.of(context).translate('login_error')),
                actions: [
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context).translate('big_ok'),
                      style: TextStyle(
                          color: Variables.primaryColor),
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
    else {
      await pr.hide();
      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(AppLocalizations.of(context).translate('error')),
              content: Text(
                  AppLocalizations.of(context).translate('login_error')),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).translate('big_ok'),
                    style: TextStyle(
                        color: Variables.primaryColor),
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getLoginInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(message: AppLocalizations.of(context).translate('please_wait'), progressWidget: Image.asset('assets/images/loading.gif'));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: ()=>FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          padding: EdgeInsets.all(26.0),
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/sidemenu_background.png'),
                  fit: BoxFit.cover)
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/back_red.png', color: Colors.white,
                      width: 24.0,
                      height: 24.0,),
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
                    width: 200
                ),
                SizedBox(
                  height: 60,
                ),
                formWidget(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RaisedButton(
                        color: Colors.black12,
                        child: Text(
                          AppLocalizations.of(context).translate('register'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => RegisterPage()
                              ));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Colors.black12,
                        child: AutoSizeText(
                          AppLocalizations.of(context).translate(
                              'forgot_password'),
                          maxLines: 1,
                          style: TextStyle(color: Colors.white,),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage()
                              ));
                        },
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Center(
                  child: InkWell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/tab_phone.png', color: Colors.white,
                          width: 24.0,
                          height: 24.0,),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text('0850 2 555 112',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          ),
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
              controller: usernameController,
              cursorColor: Colors.white,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('login_username'),
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white38,
                  filled: true,
                  counterText: '',
                  errorStyle: TextStyle(
                    color: Colors.white,
                  )
              ),
              style: TextStyle(
                  color: Colors.white
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context).translate(
                      'login_username_error');
                }
                else {
                  return null;
                }
              }
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            obscureText: true,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate(
                    'login_password'),
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                  color: Colors.white,
                )
            ),
            style: TextStyle(
                color: Colors.white
            ),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).translate('password_error');
              }
              else {
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
            child: RaisedButton(
              color: Colors.black12,
              child: Text(AppLocalizations.of(context).translate('login'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0),
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
