import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/cityModel.dart';
import 'package:klinix/models/requestModel.dart';
import 'package:klinix/models/specialserviceModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class SpecialServicesPage extends StatefulWidget {
  @override
  _SpecialServicesPageState createState() => _SpecialServicesPageState();
}

class _SpecialServicesPageState extends State<SpecialServicesPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SpecialserviceModel> _serviceList = new List<SpecialserviceModel>();
  List<CityModel> _cityList = new List<CityModel>();
  String _city;

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getSpecialservices?lang=' + Variables.lang,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _serviceList = decodeList.map((i) =>
          SpecialserviceModel.fromJson(i)).toList();

      res = await http.get(
          Variables.url + '/getCityList',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        _cityList = decodeList.map((i) =>
            CityModel.fromJson(i)).toList();

        setState(() {

        });
      }
    }

    await pr.hide();
  }

  Future<void> acceptService(SpecialserviceModel specialservice) async {
    await pr.show();

    if (Variables.memberId != null) {
      RequestModel request = new RequestModel(
          mEMID: Variables.memberId,
          sPEID: specialservice.sSPEID,
          city: _city,
          lastStatus: 'Beklemede',
          cancelled: 0
      );
      var body = json.encode(request.toMap());
      var res = await http.post(
          Variables.url + '/addRequest',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          },
          body: body);
      if (res.statusCode == 200) {
        var returned = res.body.split('"').join('');
        if (returned.contains('ok')) {
          await showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  title: Text(
                      AppLocalizations.of(context).translate('information')),
                  content: Text(AppLocalizations.of(context).translate(
                      'succesfully_completed')),
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
                      },
                    ),
                  ],
                ),
          );
        }
        else if (returned.contains('er1')) {
          await showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  title: Text(
                      AppLocalizations.of(context).translate('error')),
                  content: Text(AppLocalizations.of(context).translate(
                      'special_service_error')),
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
                      },
                    ),
                  ],
                ),
          );
        }
      }
    }
    else {
      await showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(
                  AppLocalizations.of(context).translate('information')),
              content: Text(AppLocalizations.of(context).translate(
                  'fav_error')),
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
                  },
                ),
              ],
            ),
      );
    }

    await pr.hide();
  }

  showAlertDialog(BuildContext context, SpecialserviceModel specialservice) {
    Widget cancelButton = FlatButton(
      child: Text(AppLocalizations.of(context).translate('big_cancel')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(AppLocalizations.of(context).translate('big_ok')),
      onPressed: () {
        Navigator.of(context).pop();
        acceptService(specialservice);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).translate('confirm')),
      content: Column(
        children: [
          Text(AppLocalizations.of(context).translate('accept_service')),
          Text(AppLocalizations.of(context).translate('special_service_info')),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
                                  'assets/images/special_service.png',
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
                        'big_special_service'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
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
    return ListView.builder(
      itemCount: _serviceList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => _showDialog(context, _serviceList[index]),
          child: Container(
            width: double.infinity,
            height: 120.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(_serviceList[index].images,),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 20.0, horizontal: 10.0,),
              tileColor: Variables.primaryColor.withOpacity(0.5),
              title: Text(
                _serviceList[index].title,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
              subtitle: Text(
                _serviceList[index].message,
                style: TextStyle(color: Colors.white),
              ),
              trailing: Image.asset('assets/images/next.png', height: 24,),
            ),
          ),
        );
      },
    );
  }

  _showDialog(BuildContext context, SpecialserviceModel specialservice) async {
    await showDialog<String>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            scrollable: true,
            title: Text(specialservice.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            content: Column(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: _city,
                  style: TextStyle(color: Variables.primaryColor),
                  decoration: InputDecoration(
                    hintText: '* ' + AppLocalizations.of(context).translate(
                        'city'),
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      _city = newValue;
                    });
                  },
                  items: _cityList.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value.cityName), value: value.cityName);
                  }).toList(),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                    AppLocalizations.of(context).translate(
                        'special_service_info')),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: Text(
                      AppLocalizations.of(context).translate('big_cancel')),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: Text(
                      AppLocalizations.of(context).translate('big_confirm')),
                  onPressed: _city != null
                      ? () => acceptService(specialservice)
                      : null
              ),
            ],
          );
        },
      ),
    );
  }
}
