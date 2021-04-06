import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/hospital_detail.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalNearPage extends StatefulWidget {
  @override
  _HospitalNearPageState createState() => _HospitalNearPageState();
}

class _HospitalNearPageState extends State<HospitalNearPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<HospitalsModel> _hospitalsList = new List<HospitalsModel>();

  Future<void> getList() async {
    await pr.show();
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationServiceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      var result = permission == LocationPermission.whileInUse || permission ==
          LocationPermission.always;
      if (result) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        var res = await http.get(
            Variables.url + '/getYakinimdakiKurumlar?lat=' +
                position.latitude.toString() + '&lon=' +
                position.longitude.toString(),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            });
        if (res.statusCode == 200) {
          var decodeList = json.decode(res.body) as List<dynamic>;
          _hospitalsList = decodeList.map((i) =>
              HospitalsModel.fromJson(i)).toList();

          setState(() {

          });
        }

        await pr.hide();
      }
      else {
        await pr.hide();
        await Geolocator.requestPermission();
      }
    }
    else {
      await pr.hide();
      await Geolocator.openAppSettings();
    }
  }

  Future<void> openMap(HospitalsModel hospital) async {
    String konum = hospital.konum;
    var latitude = konum.substring(0, konum.indexOf(',')).trim();
    var longitude = konum.substring(konum.indexOf(',') + 1, konum.length)
        .trim();

    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      await showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(AppLocalizations.of(context).translate('error')),
              content: Text(
                  AppLocalizations.of(context).translate('map_error')),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).translate('big_ok'),
                    style: TextStyle(
                        color: Variables.primaryColor),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(message: AppLocalizations.of(context).translate('please_wait'), progressWidget: Image.asset('assets/images/loading.gif'));

    return SideMenu(
      key: _sideMenuKey,
      menu: MyDrawer(),
      type: SideMenuType.shrinkNSlide,
      inverse: Variables.lang=='ar'? true:false,
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
              key: _scaffoldKey,
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
                                  Icons.menu, color: Variables.primaryColor, size: 32.0,),
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
                child: bodyWidget(),
              ),
              bottomNavigationBar: MyBottomNavigationBar(),
            ),
          ]
      ),
    );
  }

  Widget bodyWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 40.0,
                color: Variables.greyColor,
              ),
              Column(
                children: [
                  Center(
                    child: Container(
                        width: 200.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center,
                          children: [
                            Material(
                              color: Colors.white,
                              elevation: 8.0,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/hospital.png',
                                  width: 40, height: 40,),
                                iconSize: 56,
                                splashColor: Variables.primaryColor,
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Center(
                    child: Text(AppLocalizations.of(context).translate(
                        'big_nearest_hospital'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(child: listViewWidget()),
        ],
      ),
    );
  }

  Widget listViewWidget() {
    return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) =>
            Divider(
              color: Colors.black,
            ),
        itemCount: _hospitalsList.length,
        itemBuilder: (context, index) =>
            customListTile(_hospitalsList[index])
    );
  }

  Widget customListTile(HospitalsModel hospital) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            new MaterialPageRoute(
                builder: (context) =>
                    HospitalDetailPage(
                      hospital: hospital,
                    )
            ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new IntrinsicHeight(
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // new Container(
              //   margin: const EdgeInsets.only(
              //       top: 4.0, bottom: 4.0, right: 10.0),
              //   child: Image.asset(
              //     'assets/images/hospital_lead.png', width: 32, height: 32,),
              // ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(hospital.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Variables.primaryColor,
                            fontSize: 16.0,
                          )),
                      Row(
                        children: [
                          Text(
                              hospital.sehir ?? ''),
                          Text(
                              hospital.ilce != null ? ' / ' : ''),
                          Text(
                              hospital.ilce ?? ''),
                        ],
                      ),
                      Text(
                          hospital.category ?? ''),
                    ],
                  ),
                ),
              ),
              hospital.indirim > 0 ? new Container(
                width: 64.0,
                height: 32.0,
                padding: EdgeInsets.only(top: 15.0),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/discount.png'),
                        fit: BoxFit.cover
                    )
                ),
                child: Column(
                  children: [
                    Text(hospital.indirim.toStringAsFixed(0) + '%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    Text(AppLocalizations.of(context).translate('discount'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                        )
                    ),
                  ],
                ),
              ) : Center(),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 5.0),
                child: new Image.asset(
                  'assets/images/next.png', width: 18, height: 18,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
