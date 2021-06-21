import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/models/tokenModel.dart';
import 'package:klinix/pages/appointments.dart';
import 'package:klinix/pages/department.dart';
import 'package:klinix/pages/doctor.dart';
import 'package:klinix/pages/hospital.dart';
import 'package:klinix/pages/login.dart';
import 'package:klinix/pages/pharmacy.dart';
import 'package:klinix/pages/special_services.dart';
import 'package:klinix/ui/helper/AppLanguage.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int initScreen;
  ProgressDialog pr;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> getToken() async {
    if (Variables.accessToken == null) {
      await pr.show();

      var response = await http.post(Variables.tokenUrl, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: {
        'grant_type': 'password',
        'username': Variables.tokenUser,
        'password': Variables.tokenPass
      });
      if (response.statusCode == 200) {
        var result = TokenModel.fromJson(json.decode(response.body));
        Variables.accessToken = result.accessToken;

        final prefs = await SharedPreferences.getInstance();
        String username = prefs.get("username") ?? '';
        String passw = prefs.get("password") ?? '';
        var res = await http.get(
            Variables.url +
                '/memberLogin?username=' +
                username +
                '&password=' +
                passw,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            });
        if (res.statusCode == 200) {
          var decodeList = json.decode(res.body) as List<dynamic>;
          List<MembersModel> memberList =
              decodeList.map((i) => MembersModel.fromJson(i)).toList();

          if (memberList.length > 0) {
            Variables.memberId = memberList[0].mEMID;
            Variables.tckn = memberList[0].tCKN;
            Variables.gsm = memberList[0].gSM;
            Variables.adsoyad = memberList[0].name;
            Variables.email = memberList[0].eMail;
            Variables.sex = memberList[0].sex;

            setState(() {});
          }
        }
      }

      await pr.hide();
    }
  }

  void setDefaultLanguage() {
    if (Variables.lang == null) {
      Variables.lang = 'tr';
    }
  }

  @override
  void initState() {
    setDefaultLanguage();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getToken();
    });

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
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('token registered');
    });
    _firebaseMessaging.getToken().then((token) {
      print('token:' + token);
    });
  }

  DateTime currentBackPressTime;
  int popped = 0;

  Future<bool> onWillPop() async {
    DateTime initTime = DateTime.now();
    popped += 1;
    if (popped >= 2) {
      SystemNavigator.pop();
      return false;
    }
    await _scaffoldKey.currentState
        // ignore: deprecated_member_use
        .showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('double_tap_exit'),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ))
        .closed;

    if (DateTime.now().difference(initTime) >= Duration(seconds: 2)) {
      popped = 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    if (Variables.lang == null) appLanguage.changeLanguage(Locale('tr'));
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(
        message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

    return sideMenuWidget(appLanguage);
  }

  Widget sideMenuWidget(appLanguage) {
    return SideMenu(
      key: _sideMenuKey,
      menu: MyDrawer(),
      type: SideMenuType.shrinkNSlide,
      inverse: Variables.lang == 'ar' ? true : false,
      background: Variables.primaryColor,
      radius: BorderRadius.circular(0),
      child: WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              final _state = _sideMenuKey.currentState;
              if (_state.isOpened) {
                _state.closeSideMenu();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/home_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20.0,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Variables.primaryColor,
                            size: 32,
                          ),
                          onPressed: () {
                            final _state = _sideMenuKey.currentState;
                            if (_state.isOpened) {
                              _scaffoldKey.currentState.openEndDrawer();
                              _state.closeSideMenu();
                            } else {
                              _scaffoldKey.currentState.openDrawer();
                              _state.openSideMenu();
                            }
                          },
                        ),
                        Variables.adsoyad != null
                            ? Text(
                                AppLocalizations.of(context)
                                        .translate('hello') +
                                    '\n' +
                                    Variables.adsoyad,
                                style: TextStyle(fontSize: 12.0))
                            : Text(
                                AppLocalizations.of(context)
                                        .translate('hello') +
                                    '\n' +
                                    AppLocalizations.of(context)
                                        .translate('welcome'),
                                style: TextStyle(fontSize: 12.0),
                              ),
                        Spacer(),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/language_selector.png',
                            width: 24,
                          ),
                          onPressed: () => _localizeDialog(appLanguage),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                    bodyWidget(),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: MyBottomNavigationBar(),
        ),
        onWillPop: onWillPop,
      ),
    );
  }

  Widget bodyWidget() {
    double iconW = 42.0;
    double iconH = 42.0;
    double cardWidth = MediaQuery.of(context).size.width / 4.5;
    double cardHeight = MediaQuery.of(context).size.height / 10;

    return Padding(
      padding: EdgeInsets.only(left: 26.0, right: 26.0, bottom: 10.0),
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 200.0,
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: cardWidth / cardHeight,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
            children: <Widget>[
              InkWell(
                child: cards(
                    Image.asset(
                      'assets/images/hospital.png',
                      width: iconW,
                      height: iconH,
                    ),
                    AppLocalizations.of(context).translate('big_hospitals')),
                onTap: () {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened)
                    _state.closeSideMenu();
                  else
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => HospitalPage()));
                },
              ),
              InkWell(
                child: cards(
                    Image.asset(
                      'assets/images/doctor.png',
                      width: iconW,
                      height: iconH,
                    ),
                    AppLocalizations.of(context).translate('big_doctors')),
                onTap: () {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened)
                    _state.closeSideMenu();
                  else
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => DoctorPage()));
                },
              ),
              InkWell(
                child: cards(
                    Image.asset(
                      'assets/images/department.png',
                      width: iconW,
                      height: iconH,
                    ),
                    AppLocalizations.of(context).translate('big_departments')),
                onTap: () {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened)
                    _state.closeSideMenu();
                  else
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => DepartmentPage()));
                },
              ),
              InkWell(
                child: cards(
                    Image.asset(
                      'assets/images/appointment.png',
                      width: iconW,
                      height: iconH,
                    ),
                    AppLocalizations.of(context)
                        .translate('online_appointment')),
                onTap: () {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened)
                    _state.closeSideMenu();
                  else {
                    if (Variables.memberId != null) {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) => AppointmentsPage()));
                    } else {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) => LoginPage(
                                destination: 'appointment',
                              )));
                    }
                  }
                },
              ),
              InkWell(
                child: cards(
                    Image.asset(
                      'assets/images/pharmacy.png',
                      width: iconW,
                      height: iconH,
                    ),
                    AppLocalizations.of(context)
                        .translate('big_pharmacy_on_duty')),
                onTap: () {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened)
                    _state.closeSideMenu();
                  else
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => PharmacyPage()));
                },
              ),
              InkWell(
                child: cards(
                    Image.asset(
                      'assets/images/special_service.png',
                      width: iconW,
                      height: iconH,
                    ),
                    AppLocalizations.of(context)
                        .translate('big_special_service')),
                onTap: () async {
                  final _state = _sideMenuKey.currentState;
                  if (_state.isOpened)
                    _state.closeSideMenu();
                  else {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => SpecialServicesPage()));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cards(Image image, title) {
    return Material(
        elevation: 8.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                image,
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: AutoSizeText(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(title,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.black
                  //     )
                  // ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _localizeDialog(AppLanguage appLanguage) async {
    switch (await showDialog<Languages>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            //title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Languages.tr);
                },
                child: const Text('Türkçe', style: TextStyle(fontSize: 18)),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Languages.en);
                },
                child: const Text('English', style: TextStyle(fontSize: 18)),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Languages.de);
                },
                child: const Text('Deutsch', style: TextStyle(fontSize: 18)),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Languages.ar);
                },
                child: const Text('عربى', style: TextStyle(fontSize: 18)),
              ),
            ],
          );
        })) {
      case Languages.tr:
        appLanguage.changeLanguage(Locale('tr'));
        break;
      case Languages.en:
        appLanguage.changeLanguage(Locale('en'));
        break;
      case Languages.de:
        appLanguage.changeLanguage(Locale('de'));
        break;
      case Languages.ar:
        appLanguage.changeLanguage(Locale('ar'));
        break;
    }
  }

  Widget languagePopupWidget(BuildContext context, AppLanguage appLanguage) {
    return PopupMenuButton<Languages>(
      icon: Icon(Icons.language),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Languages>>[
        const PopupMenuItem<Languages>(
          value: Languages.tr,
          child: Text('Türkçe'),
        ),
        const PopupMenuItem<Languages>(
          value: Languages.en,
          child: Text('English'),
        ),
        const PopupMenuItem<Languages>(
          value: Languages.de,
          child: Text('Deutsch'),
        ),
        const PopupMenuItem<Languages>(
          value: Languages.ar,
          child: Text('عربى'),
        ),
      ],
      onSelected: (Languages result) {
        if (result == Languages.tr) {
          appLanguage.changeLanguage(Locale('tr'));
        }
        if (result == Languages.en) {
          appLanguage.changeLanguage(Locale('en'));
        }
        if (result == Languages.en) {
          appLanguage.changeLanguage(Locale('de'));
        }
        if (result == Languages.ar) {
          appLanguage.changeLanguage(Locale('ar'));
        }
      },
    );
  }
}
