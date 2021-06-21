import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/favoritesModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/appointments.dart';
import 'package:klinix/pages/login.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailPage extends StatefulWidget {
  final DoctorsModel doctor;

  DoctorDetailPage({this.doctor});

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var doctorInfo = <DoctorsModel>[];
  HospitalsModel _hospital = new HospitalsModel();
  String favID;
  bool isFavorite = false;

  Future<void> getDocInfo() async {
    var res = await http.get(
        Variables.url +
            '/getDocInfo?docId=' +
            widget.doctor.dOCID.toString() +
            '&lang=' +
            Variables.lang +
            '&memberId=' +
            Variables.memberId.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      doctorInfo = decodeList.map((i) => DoctorsModel.fromJson(i)).toList();

      res = await http.get(
          Variables.url +
              '/getHospitalById?id=' +
              widget.doctor.hOSID.toString() +
              '&lang=' +
              Variables.lang,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<HospitalsModel> _hospitalsList =
            decodeList.map((i) => HospitalsModel.fromJson(i)).toList();
        if (_hospitalsList.length > 0) {
          _hospital = _hospitalsList[0];
        }
      }

      setState(() {
        if (doctorInfo.length > 0) {
          if (doctorInfo[0].info != null && doctorInfo[0].info != '') {
            favID = doctorInfo[0].info;
            isFavorite = true;
          } else {
            isFavorite = false;
            favID = null;
          }
        }
      });
    }
  }

  Future<void> openMap() async {
    if (_hospital != null) {
      String konum = _hospital.konum;
      var latitude = konum.substring(0, konum.indexOf(',')).trim();
      var longitude =
          konum.substring(konum.indexOf(',') + 1, konum.length).trim();

      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context).translate('error')),
            content: Text(AppLocalizations.of(context).translate('map_error')),
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
      }
    }
  }

  Future<void> addFavorites() async {
    if (Variables.memberId != null) {
      if (!isFavorite) {
        FavoritesModel model = new FavoritesModel(
            favtur: 1,
            favkurumid: 0,
            favdokid: widget.doctor.dOCID,
            favuyeid: Variables.memberId);
        var body = json.encode(model.toMap());
        var res = await http.post(Variables.url + '/addFavorites',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
            body: body);
        if (res.statusCode == 200) {
          getDocInfo();
          await _scaffoldKey.currentState
              // ignore: deprecated_member_use
              .showSnackBar(SnackBar(
                content: Text(
                  AppLocalizations.of(context).translate('fav_added'),
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 2),
              ))
              .closed;
        }
      } else {
        var res = await http
            .get(Variables.url + '/delFavorites?id=' + favID, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
        if (res.statusCode == 200) {
          getDocInfo();
          await _scaffoldKey.currentState
              // ignore: deprecated_member_use
              .showSnackBar(SnackBar(
                content: Text(
                  AppLocalizations.of(context).translate('fav_removed'),
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 2),
              ))
              .closed;
        }
      }
    } else {
      await _scaffoldKey.currentState
          // ignore: deprecated_member_use
          .showSnackBar(SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('fav_error'),
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ))
          .closed;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDocInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      key: _sideMenuKey,
      menu: MyDrawer(),
      type: SideMenuType.shrinkNSlide,
      inverse: Variables.lang == 'ar' ? true : false,
      background: Variables.primaryColor,
      radius: BorderRadius.circular(0),
      child: Stack(children: [
        Image(
          image: AssetImage("assets/images/home_background.png"),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Variables.greyColor,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Stack(children: [
              Container(
                width: 80.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: Image.asset(
                          'assets/images/back_red.png',
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Variables.primaryColor,
                          size: 32.0,
                        ),
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
                child: Center(
                    child: Image.asset(
                  'assets/images/logo.png',
                  width: 100.0,
                )),
              ),
            ]),
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: 150.0,
                  color: Variables.greyColor,
                ),
                Column(
                  children: [
                    Center(
                      child: Container(
                          padding: EdgeInsets.only(top: 70.0),
                          width: 250.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                color: Colors.white,
                                elevation: 8.0,
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(50),
                                child: IconButton(
                                  icon: Image.asset(
                                    'assets/images/pin.png',
                                    width: 18,
                                    height: 18,
                                    color: Variables.primaryColor,
                                  ),
                                  iconSize: 24,
                                  splashColor: Variables.primaryColor,
                                  onPressed: () => openMap(),
                                ),
                              ),
                              Material(
                                color: Colors.white,
                                elevation: 0,
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(90),
                                child: widget.doctor.photoPath == null
                                    ? IconButton(
                                        icon: Image.asset(
                                          'assets/images/doctor_button.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                        iconSize: 140,
                                        onPressed: null,
                                      )
                                    : CircleAvatar(
                                        radius: 65,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 62,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              widget.doctor.photoPath),
                                        ),
                                      ),
                              ),
                              Material(
                                color: isFavorite == false
                                    ? Colors.white
                                    : Variables.primaryColor,
                                elevation: 8.0,
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(50),
                                child: IconButton(
                                  icon: Image.asset(
                                      'assets/images/tab_heart.png',
                                      width: 24.0,
                                      height: 24.0,
                                      color: isFavorite == false
                                          ? Variables.primaryColor
                                          : Colors.white),
                                  iconSize: 24,
                                  splashColor: Variables.primaryColor,
                                  onPressed: () => addFavorites(),
                                ),
                              ),
                            ],
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              widget.doctor.name,
                              style: TextStyle(
                                  color: Variables.primaryColor,
                                  fontSize: 20.0),
                            ),
                          ),
                          Center(
                            child: Text(
                              widget.doctor.title,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          RawMaterialButton(
                            fillColor: Variables.primaryColor,
                            splashColor: Variables.greyColor,
                            textStyle: TextStyle(color: Colors.white),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('big_make_appointment'),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.navigate_next)
                              ],
                            ),
                            onPressed: () {
                              if (Variables.memberId != null) {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                        builder: (context) => AppointmentsPage(
                                              hospital: _hospital,
                                              doctor: widget.doctor,
                                            )));
                              } else {
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                        builder: (context) => LoginPage(
                                              destination: 'appointment',
                                              hospital: _hospital,
                                              doctor: widget.doctor,
                                            )));
                              }
                            },
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Table(
                              columnWidths: {
                                0: FlexColumnWidth(40.0),
                                1: FlexColumnWidth(10.0),
                                2: FlexColumnWidth(70.0),
                              },
                              children: [
                                TableRow(children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('worked_hospital'),
                                    textAlign: TextAlign.right,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(doctorInfo.length > 0
                                      ? doctorInfo[0].p1
                                      : ' '),
                                ]),
                                TableRow(children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('worked_city'),
                                    textAlign: TextAlign.right,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  _hospital.sehir != null
                                      ? Text(_hospital.category +
                                          ' / ' +
                                          _hospital.sehir)
                                      : Text(''),
                                ]),
                                TableRow(children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('worked_department'),
                                    textAlign: TextAlign.right,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(doctorInfo.length > 0
                                      ? doctorInfo[0].p2
                                      : ' '),
                                ]),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50.0,
                          ),
                          Html(
                            data: doctorInfo.length > 0
                                ? doctorInfo[0].p3
                                : '<br />',
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: MyBottomNavigationBar(),
        ),
      ]),
    );
  }
}
