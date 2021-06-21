import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:klinix/models/favoritesModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/appointments.dart';
import 'package:klinix/pages/department.dart';
import 'package:klinix/pages/doctor.dart';
import 'package:klinix/pages/login.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailPage extends StatefulWidget {
  final HospitalsModel hospital;

  HospitalDetailPage({this.hospital});

  @override
  _HospitalDetailPageState createState() => _HospitalDetailPageState();
}

class _HospitalDetailPageState extends State<HospitalDetailPage> {
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String favID;
  bool isFavorite = false;

  Future<void> getFavorite() async {
    if (widget.hospital != null && Variables.memberId != null) {
      var res = await http.get(
          Variables.url +
              '/getFavoritesByHospital?hosId=' +
              widget.hospital.hOSID.toString() +
              '&memberId=' +
              Variables.memberId.toString(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<FavoritesModel> _favoritesList =
            decodeList.map((i) => FavoritesModel.fromJson(i)).toList();
        if (_favoritesList.length > 0) {
          setState(() {
            isFavorite = true;
            favID = _favoritesList[0].fAVID.toString();
          });
        } else {
          setState(() {
            isFavorite = false;
            favID = null;
          });
        }
      } else {
        setState(() {
          isFavorite = false;
          favID = null;
        });
      }
    } else {
      setState(() {
        isFavorite = false;
        favID = null;
      });
    }
  }

  Future<void> openMap() async {
    String konum = widget.hospital.konum;
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

  Future<void> addFavorites() async {
    if (Variables.memberId != null) {
      if (!isFavorite) {
        FavoritesModel model = new FavoritesModel(
            favtur: 2,
            favkurumid: widget.hospital.hOSID,
            favdokid: 0,
            favuyeid: Variables.memberId);
        var body = json.encode(model.toMap());
        var res = await http.post(Variables.url + '/addFavorites',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
            body: body);
        if (res.statusCode == 200) {
          getFavorite();
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
          getFavorite();
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
      getFavorite();
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                              Center(
                                child: Material(
                                  color: Colors.white,
                                  elevation: 0,
                                  clipBehavior: Clip.hardEdge,
                                  borderRadius: BorderRadius.circular(90),
                                  child: widget.hospital.logoPath == null
                                      ? IconButton(
                                          icon: Image.asset(
                                            'assets/images/hospital_button.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                          iconSize: 140,
                                          onPressed: null,
                                        )
                                      : CircleAvatar(
                                          radius: 65,
                                          backgroundColor: Colors.white,
                                          child: Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Image.network(
                                              widget.hospital.logoPath,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
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
                          vertical: 20.0, horizontal: 50.0),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              widget.hospital.name +
                                      '/' +
                                      widget.hospital.sehir ??
                                  '',
                              style: TextStyle(
                                  color: Variables.primaryColor,
                                  fontSize: 20.0),
                            ),
                          ),
                          Center(
                            child: Text(
                              widget.hospital.category,
                            ),
                          ),
                          Center(
                            child: Text(
                              widget.hospital.adres,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          widget.hospital.indirim > 0
                              ? Container(
                                  width: 85.0,
                                  height: 32.0,
                                  padding: EdgeInsets.only(top: 2.0),
                                  alignment: Alignment.bottomCenter,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/discount.png'),
                                          fit: BoxFit.cover)),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.hospital.indirim
                                                .toStringAsFixed(0) +
                                            '%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                          AppLocalizations.of(context)
                                              .translate('discount'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.0,
                                          )),
                                    ],
                                  ),
                                )
                              : Center(),
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
                              if (widget.hospital.anlasmavarmi == "1") {
                                if (Variables.memberId != null) {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              AppointmentsPage(
                                                hospital: widget.hospital,
                                              )));
                                } else {
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(
                                          builder: (context) => LoginPage(
                                                destination: 'appointment',
                                                hospital: widget.hospital,
                                              )));
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(AppLocalizations.of(context)
                                        .translate('information')),
                                    content: Text(AppLocalizations.of(context)
                                        .translate('not_agreement')),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('big_ok'),
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
                            },
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Divider(
                            color: Colors.black,
                          ),
                          ListTile(
                            leading: Image.asset(
                              'assets/images/department_lead.png',
                              width: 20.0,
                              height: 20.0,
                            ),
                            title: Text(
                              AppLocalizations.of(context)
                                  .translate('departments'),
                              style: TextStyle(fontSize: 16.0),
                            ),
                            trailing: Image.asset(
                              'assets/images/next.png',
                              width: 20.0,
                              height: 20.0,
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => DepartmentPage(
                                        hospital: widget.hospital,
                                      )));
                            },
                          ),
                          Divider(
                            color: Colors.black,
                          ),
                          ListTile(
                            leading: Image.asset(
                              'assets/images/doctor_lead.png',
                              width: 20.0,
                              height: 20.0,
                            ),
                            title: Text(
                              AppLocalizations.of(context).translate('doctors'),
                              style: TextStyle(fontSize: 16.0),
                            ),
                            trailing: Image.asset(
                              'assets/images/next.png',
                              width: 20.0,
                              height: 20.0,
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => DoctorPage(
                                        hospitalId: widget.hospital.hOSID,
                                      )));
                            },
                          ),
                          Divider(
                            color: Colors.black,
                          ),
                          ListTile(
                            leading: Image.asset(
                              'assets/images/pin.png',
                              width: 20.0,
                              height: 20.0,
                            ),
                            title: Text(
                              AppLocalizations.of(context).translate('where'),
                              style: TextStyle(fontSize: 16.0),
                            ),
                            trailing: Image.asset(
                              'assets/images/next.png',
                              width: 20.0,
                              height: 20.0,
                            ),
                            dense: true,
                            onTap: () => openMap(),
                          ),
                          Divider(
                            color: Colors.black,
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
