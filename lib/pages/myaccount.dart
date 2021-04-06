import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:klinix/ui/widgets/sms_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class MyAccountPage extends StatefulWidget {
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  MembersModel member = new MembersModel();
  final emailController = new TextEditingController();
  final gsmController = new TextEditingController();
  String _cinsiyet;
  String _memberSex;

  Future<void> getMember() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getMemberById?id=' + Variables.memberId.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      List<MembersModel> _membersList = decodeList.map((i) =>
          MembersModel.fromJson(i)).toList();
      if (_membersList.length > 0) {
        setState(() {
          member = _membersList[0];
          emailController.text = member.eMail;
          if (member.sex == 'E') {
            _cinsiyet = 'Erkek';
            _memberSex = 'Erkek';
          }
          else if (member.sex == 'K') {
            _cinsiyet = 'Kadın';
            _memberSex = 'Kadın';
          }
        });
      }
    }

    await pr.hide();
  }

  Future<void> update() async {
    await pr.show();

    if (member != null) {
      if (member.eMail != emailController.text) {
        var res = await http.get(
          Variables.url + '/checkMemberByEmail?email=' + emailController.text,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          },
        );
        if (res.statusCode == 200) {
          var decodeList = json.decode(res.body) as List<dynamic>;
          List<MembersModel> memberList = decodeList.map((i) =>
              MembersModel.fromJson(i)).toList();
          if (memberList.length == 0) {
            MembersModel insertedMember = new MembersModel(
                mEMID: member.mEMID,
                eMail: emailController.text.toLowerCase(),
                sex: _cinsiyet.substring(0, 1)
            );
            var body = json.encode(insertedMember.toMap());
            res = await http.post(
                Variables.url + '/addMember',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'bearer ' + Variables.accessToken
                },
                body: body);
            if (res.statusCode == 200) {
              await getMember();
              Navigator.of(context).pop();
            }
          }
          else {
            await showDialog(
              context: context,
              builder: (_) =>
                  AlertDialog(
                    title: Text(AppLocalizations.of(context).translate(
                        'error')),
                    content: Text(AppLocalizations.of(context).translate(
                        'email_update_error')),
                    actions: [
                      TextButton(
                        child: Text(AppLocalizations.of(context).translate(
                            'big_ok'),
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
      }
      else {
        MembersModel insertedMember = new MembersModel(
            mEMID: member.mEMID,
            eMail: emailController.text.toLowerCase(),
            sex: _cinsiyet.substring(0, 1)
        );
        var body = json.encode(insertedMember.toMap());
        var res = await http.post(
            Variables.url + '/addMember',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
            body: body);
        if (res.statusCode == 200) {
          await getMember();
          Navigator.of(context).pop();
        }
      }
    }

    await pr.hide();
  }

  Future<void> changeNumber() async {
    if (member.gSM != gsmController.text) {
      await pr.show();

      var res = await http.get(
        Variables.url + '/checkMemberByGsm?gsm=' + gsmController.text,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        },
      );
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<MembersModel> memberList = decodeList.map((i) =>
            MembersModel.fromJson(i)).toList();
        if (memberList.length == 0) {
          var res = await http.get(
              Variables.url + '/changeGsm?memberId=' +
                  Variables.memberId.toString()
                  + '&newgsm=' + gsmController.text,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'bearer ' + Variables.accessToken
              });
          if (res.statusCode == 200) {
            var sms = res.body.split('"').join('');
            String smsDialogResult = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  SmsDialog(
                    title: AppLocalizations.of(context).translate(
                        'enter_sms_code'),
                    buttonText: AppLocalizations.of(context).translate(
                        'big_ok'),
                    smscode: sms,
                  ),
            );

            if (smsDialogResult != '') {
              MembersModel insertedMember = new MembersModel(
                  mEMID: member.mEMID,
                  gSM: gsmController.text,
                  teldogrulandi: 1,
                  sMSCodezaman: DateTime.now().toString()
              );
              var body = json.encode(insertedMember.toMap());
              res = await http.post(
                  Variables.url + '/addMember',
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'bearer ' + Variables.accessToken
                  },
                  body: body);
              if (res.statusCode == 200) {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString("username", gsmController.text);

                await showDialog(
                  context: context,
                  builder: (_) =>
                      AlertDialog(
                        title: Text(AppLocalizations.of(context).translate(
                            'information')),
                        content: Text(AppLocalizations.of(context).translate(
                            'phone_changed')),
                        actions: [
                          TextButton(
                            child: Text(AppLocalizations.of(context).translate(
                                'big_ok'),
                              style: TextStyle(
                                  color: Variables.primaryColor),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              getMember();
                            },
                          ),
                        ],
                      ),
                );
              }
            }
          }
        }
        else {
          await showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  title: Text(AppLocalizations.of(context).translate(
                      'error')),
                  content: Text(AppLocalizations.of(context).translate(
                      'gsm_update_error')),
                  actions: [
                    TextButton(
                      child: Text(AppLocalizations.of(context).translate(
                          'big_ok'),
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

      await pr.hide();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getMember();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

    return SideMenu(
      key: _sideMenuKey,
      menu: MyDrawer(),
      type: SideMenuType.shrinkNSlide,
      inverse: Variables.lang == 'ar' ? true : false,
      background: Variables.primaryColor,
      radius: BorderRadius.circular(0),
      child: Stack(
          children: [
            Image(
              image: AssetImage("assets/images/home_background.png"),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              fit: BoxFit.cover,
            ),

            Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Variables.greyColor,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Stack(
                    children: [
                      Container(
                        width: 80.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/back_red.png',),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(
                                  Icons.menu, color: Variables.primaryColor,
                                  size: 32.0,),
                                onPressed: () {
                                  final _state = _sideMenuKey.currentState;
                                  if (_state.isOpened)
                                    _state.closeSideMenu();
                                  else
                                    _state.openSideMenu();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Center(child: Image.asset(
                          'assets/images/logo.png', width: 100.0,)),
                      ),
                    ]
                ),
              ),
              body: GestureDetector(
                onTap: () {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened) {
                    _state.closeSideMenu();
                  }
                },
                child: Container(
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/white_background.png'),
                          fit: BoxFit.cover)
                  ),
                  child: bodyWidget(),
                ),
              ),

              bottomNavigationBar: MyBottomNavigationBar(),
            ),

          ]
      ),
    );
  }

  Widget bodyWidget() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 40.0,
              width: double.infinity,
              color: Variables.greyColor,
            ),
            Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: Material(
                    color: Colors.white,
                    elevation: 8.0,
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(50),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/hospital_button.png',
                        width: 40, height: 40,),
                      iconSize: 56,
                      splashColor: Variables.primaryColor,
                    ),
                  ),
                ),

                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate('my_profile'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),

                SizedBox(
                  height: 10.0,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 30.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Variables.primaryColor
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(AppLocalizations.of(context).translate(
                                'identity_info'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      listTileWidget(
                          AppLocalizations.of(context).translate('name') + ' ' +
                              AppLocalizations.of(context).translate('surname'),
                          member.name != null ? member.name : ' '),
                      listTileWidget(AppLocalizations.of(context).translate(
                          'identity_number'),
                          member.tCKN != null ? member.tCKN : ' '),
                      listTileWidget(
                          AppLocalizations.of(context).translate('birth_date'),
                          member.bDate != null ? DateFormat('dd.MM.yyyy')
                              .format(
                              DateTime.parse(member.bDate)) : ' '),
                      listTileWidget(AppLocalizations.of(context).translate(
                          'sex'),
                          _memberSex ?? ''),
                    ],
                  ),
                ),

                SizedBox(
                  height: 10.0,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 30.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Variables.primaryColor
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(AppLocalizations.of(context).translate(
                                'contact_info'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10.0,
                      ),

                      listTileWidget(AppLocalizations.of(context).translate(
                          'login_email'),
                          member.eMail != null ? member.eMail : ' '),
                      listTileWidget(
                          AppLocalizations.of(context).translate('cell_phone'),
                          member.gSM != null ? member.gSM : ' '),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 60.0, vertical: 10.0),
                  child: Container(
                    width: double.infinity,
                    child: RawMaterialButton(
                      elevation: 0,
                      fillColor: Variables.primaryColor,
                      splashColor: Colors.white,
                      textStyle: TextStyle(color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 40.0),
                              child: Text(
                                AppLocalizations.of(context).translate(
                                    'change_phone'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Image.asset(
                              'assets/images/next.png', color: Colors.white,
                              width: 20.0,
                              height: 20.0,),
                          ),
                        ],
                      ),
                      onPressed: () => _changePhoneDialog(),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 60.0,),
                  child: Container(
                    width: double.infinity,
                    child: RawMaterialButton(
                      elevation: 0,
                      fillColor: Variables.primaryColor,
                      splashColor: Colors.white,
                      textStyle: TextStyle(color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 40.0),
                              child: Text(
                                AppLocalizations.of(context).translate(
                                    'update_info'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Image.asset(
                              'assets/images/next.png', color: Colors.white,
                              width: 20.0,
                              height: 20.0,),
                          ),
                        ],
                      ),
                      onPressed: () => _showDialog(),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listTileWidget(String title, String trailingText) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: Text(trailingText),
          dense: true,
        ),
        Divider(
          color: Colors.black,
          height: 5.0,
        ),
      ],
    );
  }

  _changePhoneDialog() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        scrollable: true,
        title: Text(AppLocalizations.of(context).translate('change_phone')),
        content: Column(
          children: <Widget>[
            TextField(
              controller: gsmController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('cell_phone'),
                prefix: Text('+90', style: TextStyle(color: Colors.black),),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: Text(AppLocalizations.of(context).translate('big_cancel')),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: Text(AppLocalizations.of(context).translate('big_save')),
              onPressed: () => changeNumber()
          ),
        ],
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        scrollable: true,
        title: Text(AppLocalizations.of(context).translate('update_info')),
        content: Column(
          children: <Widget>[
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('email'),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _cinsiyet,
              style: TextStyle(color: Variables.primaryColor),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'sex'),
              ),
              onChanged: (String newValue) {
                setState(() {
                  _cinsiyet = newValue;
                });
              },
              items: <String>['Erkek', 'Kadın']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: Text(AppLocalizations.of(context).translate('big_cancel')),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: Text(AppLocalizations.of(context).translate('big_save')),
              onPressed: () => update()
          ),
        ],
      ),
    );
  }
}
