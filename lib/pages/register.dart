import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:klinix/models/devicesModel.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/pages/contract.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/sms_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  ProgressDialog pr;
  final _formKey = GlobalKey<FormState>();
  final adController = new TextEditingController();
  final soyadController = new TextEditingController();
  final tcknController = new TextEditingController();
  final gsmController = new TextEditingController();
  final FocusNode adFocus = new FocusNode();
  final FocusNode soyadFocus = new FocusNode();
  final FocusNode tcknFocus = new FocusNode();
  final FocusNode gsmFocus = new FocusNode();

  List<String> birthDays = [], birthMonths = [], birthYears = [];
  String bday = DateTime.now().day.toString().padLeft(2, '0'),
      bmonth = DateTime.now().month.toString().padLeft(2, '0'),
      byear = DateTime.now().year.toString();
  bool _sozlesme = false;
  int _radioValue = 2;

  Future<void> checkMember() async {
    var res = await http.get(
      Variables.url + '/checkMember?tckn=' + tcknController.text,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer ' + Variables.accessToken
      },
    );
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      List<MembersModel> memberList =
          decodeList.map((i) => MembersModel.fromJson(i)).toList();
      if (memberList.length == 0) {
        register();
      } else {
        _showDialog(AppLocalizations.of(context).translate('error'),
            AppLocalizations.of(context).translate('exists_member_error'));
      }
    }
  }

  Future<void> register() async {
    await pr.show();

    var res = await http.get(
      Variables.url +
          '/kimlikDogrula?tckn=' +
          tcknController.text +
          '&ad=' +
          adController.text +
          '&soyad=' +
          soyadController.text +
          '&dogumTarihi=' +
          bday +
          '.' +
          bmonth +
          '.' +
          byear,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer ' + Variables.accessToken
      },
    );
    if (res.statusCode == 200) {
      var result = res.body.split('"').join('');
      if (result == "true") {
        MembersModel member = new MembersModel(
            name: adController.text + ' ' + soyadController.text,
            tCKN: tcknController.text,
            gSM: gsmController.text,
            bDate: byear + '-' + bmonth + '-' + bday,
            cancelled: 1);
        var body = json.encode(member.toMap());
        res = await http.post(Variables.url + '/addMember',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
            body: body);
        if (res.statusCode == 200) {
          var memberId = res.body.split('"').join('');

          res = await http.get(
            Variables.url +
                '/sendSms?tckn=' +
                tcknController.text +
                '&gsm=' +
                gsmController.text,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
          );
          if (res.statusCode == 200) {
            await pr.hide();

            var sms = res.body.split('"').join('');
            String smsDialogResult = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => SmsDialog(
                title: AppLocalizations.of(context).translate('enter_sms_code'),
                buttonText: AppLocalizations.of(context).translate('big_ok'),
                smscode: sms,
              ),
            );

            if (smsDialogResult != '') {
              MembersModel insertedMember = new MembersModel(
                  mEMID: int.parse(memberId),
                  teldogrulandi: 1,
                  sMSCodezaman: DateTime.now().toString(),
                  cancelled: 0);
              var body = json.encode(insertedMember.toMap());
              res = await http.post(Variables.url + '/addMember',
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'bearer ' + Variables.accessToken
                  },
                  body: body);
              if (res.statusCode == 200) {
                res = await http.get(
                    Variables.url +
                        '/getMemberById?id=' +
                        insertedMember.mEMID.toString(),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'bearer ' + Variables.accessToken
                    });
                if (res.statusCode == 200) {
                  var decodeList = json.decode(res.body) as List<dynamic>;
                  List<MembersModel> memberList =
                      decodeList.map((i) => MembersModel.fromJson(i)).toList();

                  if (memberList.length > 0) {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("username", gsmController.text);
                    prefs.setString("password", sms);

                    Variables.memberId = insertedMember.mEMID;
                    Variables.tckn = memberList[0].tCKN;
                    Variables.gsm = memberList[0].gSM;
                    Variables.adsoyad = memberList[0].name;
                    Variables.email = memberList[0].eMail;
                    Variables.sex = memberList[0].sex;

                    final DeviceInfoPlugin deviceInfoPlugin =
                        DeviceInfoPlugin();
                    String ck, dt, dv;
                    if (Platform.isAndroid) {
                      AndroidDeviceInfo android =
                          await deviceInfoPlugin.androidInfo;
                      ck = android.androidId.substring(0, 6);
                      dt = 'android';
                    } else if (Platform.isIOS) {
                      IosDeviceInfo ios = await deviceInfoPlugin.iosInfo;
                      ck = ios.identifierForVendor.substring(0, 6);
                      dt = 'ios';
                    }
                    final FirebaseMessaging _firebaseMessaging =
                        FirebaseMessaging();
                    _firebaseMessaging.configure(
                      // ignore: missing_return
                      onLaunch: (Map<String, dynamic> message) {
                        print('onLaunch called');
                      },
                      // ignore: missing_return
                      onResume: (Map<String, dynamic> message) {
                        print('onResume called');
                      },
                      // ignore: missing_return
                      onMessage: (Map<String, dynamic> message) {
                        print('onMessage called');
                      },
                    );
                    _firebaseMessaging.subscribeToTopic('all');
                    _firebaseMessaging
                        .requestNotificationPermissions(IosNotificationSettings(
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
                          mEMID: insertedMember.mEMID, cK: ck, dT: dt, dV: dv);
                      var body = json.encode(device.toMap());
                      res = await http.post(Variables.url + '/addDevice',
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'bearer ' + Variables.accessToken
                          },
                          body: body);
                      if (res.statusCode == 200) {}
                    });

                    DevicesModel device = new DevicesModel(
                        mEMID: insertedMember.mEMID, cK: ck, dT: dt, dV: dv);
                    var body = json.encode(device.toMap());
                    res = await http.post(Variables.url + '/addDevice',
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'bearer ' + Variables.accessToken
                        },
                        body: body);
                    if (res.statusCode == 200) {}
                  }
                }

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                        AppLocalizations.of(context).translate('information')),
                    content: Text(AppLocalizations.of(context)
                        .translate('register_completed')),
                    actions: [
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context).translate('big_ok'),
                          style: TextStyle(color: Variables.primaryColor),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    ],
                  ),
                );
              }
            }
          }
        } else {
          await pr.hide();

          String errorMessage =
              AppLocalizations.of(context).translate('register_error') +
                  '\n' +
                  res.statusCode.toString() +
                  ': ' +
                  res.reasonPhrase;
          _showDialog(
              AppLocalizations.of(context).translate('error'), errorMessage);
        }
      } else {
        await pr.hide();

        _showDialog(
            AppLocalizations.of(context).translate('error'),
            AppLocalizations.of(context)
                .translate('identity_number_incorrect'));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    for (int i = 1; i < 32; i++) {
      birthDays.add(i.toString().padLeft(2, '0'));
    }
    for (int i = 1; i < 13; i++) {
      birthMonths.add(i.toString().padLeft(2, '0'));
    }
    for (int i = 0; i < 81; i++) {
      birthYears.add(((DateTime.now().year - 80) + i).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(
        message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

    return Scaffold(
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
            child: SingleChildScrollView(
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

                  Container(
                      child: Image.asset('assets/images/logo_white.png'),
                      width: 180),
                  SizedBox(
                    height: 20,
                  ),

                  formWidget(),

                  //Spacer(),

                  SizedBox(
                    height: 20,
                  ),
                  Center(
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
                  ),
                ],
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: adController,
                  focusNode: adFocus,
                  cursorColor: Colors.white,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('register_name'),
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
                          .translate('register_name_error');
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: TextFormField(
                  controller: soyadController,
                  focusNode: soyadFocus,
                  cursorColor: Colors.white,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                          .translate('register_surname'),
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
                          .translate('register_surname_error');
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: tcknController,
            focusNode: tcknFocus,
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
            style: TextStyle(
              color: Colors.white,
            ),
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
            height: 5,
          ),
          TextFormField(
            controller: gsmController,
            focusNode: gsmFocus,
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
            height: 5,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Doğum Tarihi',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: bday,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('day'),
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: AppLocalizations.of(context).translate('day'),
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white38,
                    filled: true,
                    errorStyle: TextStyle(color: Colors.white),
                  ),
                  icon: Image.asset(
                    'assets/images/dropdown.png',
                    width: 18.0,
                    height: 18.0,
                  ),
                  items: birthDays.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value), value: value);
                  }).toList(),
                  validator: (value) => value == null
                      ? AppLocalizations.of(context).translate('required_field')
                      : null,
                  onChanged: (value) {
                    setState(() {
                      bday = value;
                    });
                  },
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: bmonth,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('month'),
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: AppLocalizations.of(context).translate('month'),
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white38,
                    filled: true,
                    errorStyle: TextStyle(color: Colors.white),
                  ),
                  icon: Image.asset(
                    'assets/images/dropdown.png',
                    width: 18.0,
                    height: 18.0,
                  ),
                  items: birthMonths.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value), value: value);
                  }).toList(),
                  validator: (value) => value == null
                      ? AppLocalizations.of(context).translate('required_field')
                      : null,
                  onChanged: (value) {
                    setState(() {
                      bmonth = value;
                    });
                  },
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: byear,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('year'),
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: AppLocalizations.of(context).translate('year'),
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white38,
                    filled: true,
                    errorStyle: TextStyle(color: Colors.white),
                  ),
                  icon: Image.asset(
                    'assets/images/dropdown.png',
                    width: 18.0,
                    height: 18.0,
                  ),
                  items: birthYears.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value), value: value);
                  }).toList(),
                  validator: (value) => value == null
                      ? AppLocalizations.of(context).translate('required_field')
                      : null,
                  onChanged: (value) {
                    setState(() {
                      byear = value;
                    });
                  },
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          CheckboxListTile(
            title: Text(
              AppLocalizations.of(context).translate('contract_approve'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.0,
              ),
            ),
            value: _sozlesme,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (newValue) {
              setState(() {
                _sozlesme = newValue;
              });
              if (newValue == true) {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) => ContractPage(),
                    fullscreenDialog: true));
              }
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context).translate('information_confirm'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.0,
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                child: Row(
                  children: [
                    Radio(
                      value: 1,
                      activeColor: Colors.white,
                      groupValue: _radioValue,
                      onChanged: (newValue) {
                        setState(() {
                          _radioValue = newValue;
                        });
                      },
                    ),
                    Text(
                      AppLocalizations.of(context).translate('yes'),
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _radioValue = 1;
                  });
                },
              ),
              InkWell(
                child: Row(
                  children: [
                    Radio(
                      value: 2,
                      activeColor: Colors.white,
                      groupValue: _radioValue,
                      onChanged: (newValue) {
                        setState(() {
                          _radioValue = newValue;
                        });
                      },
                    ),
                    Text(
                      AppLocalizations.of(context).translate('no'),
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _radioValue = 2;
                  });
                },
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.black12),
              child: Text(
                AppLocalizations.of(context).translate('register'),
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (_sozlesme) {
                    if (_radioValue == 1) {
                      checkMember();
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                              AppLocalizations.of(context).translate('error')),
                          content: Text(AppLocalizations.of(context)
                              .translate('information_confirm_error')),
                          actions: [
                            TextButton(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('big_ok'),
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
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                            AppLocalizations.of(context).translate('error')),
                        content: Text(AppLocalizations.of(context)
                            .translate('contract_error')),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
