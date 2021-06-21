import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/favoritesModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/doctor_detail.dart';
import 'package:klinix/pages/hospital_detail.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class FavoritesPage extends StatefulWidget {
  final int initialIndex;

  FavoritesPage({this.initialIndex});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  var _favoriteHospitalList = <FavoritesModel>[];
  var _favoriteDoctorList = <FavoritesModel>[];

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url +
            '/getFavoritesByFavType?memberId=' +
            Variables.memberId.toString() +
            '&tur=2',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _favoriteHospitalList =
          decodeList.map((i) => FavoritesModel.fromJson(i)).toList();

      res = await http.get(
          Variables.url +
              '/getFavoritesByFavType?memberId=' +
              Variables.memberId.toString() +
              '&tur=1',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        _favoriteDoctorList =
            decodeList.map((i) => FavoritesModel.fromJson(i)).toList();
      }

      setState(() {});
    }

    await pr.hide();
  }

  Future<void> navigate(FavoritesModel favorite) async {
    if (favorite.favtur == 1) {
      var res = await http.get(
          Variables.url + '/getDoctorById?id=' + favorite.favdokid.toString(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<DoctorsModel> _list =
            decodeList.map((i) => DoctorsModel.fromJson(i)).toList();

        if (_list.length > 0) {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => DoctorDetailPage(
                    doctor: _list[0],
                  )));
        }
      }
    } else {
      var res = await http.get(
          Variables.url +
              '/getHospitalById?id=' +
              favorite.favkurumid.toString(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<HospitalsModel> _list =
            decodeList.map((i) => HospitalsModel.fromJson(i)).toList();

        if (_list.length > 0) {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => HospitalDetailPage(
                    hospital: _list[0],
                  )));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(
        message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

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
      ]),
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
                        'assets/images/tab_heart.png',
                        width: 40,
                        height: 40,
                      ),
                      iconSize: 56,
                      splashColor: Variables.primaryColor,
                      onPressed: null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate('big_favorites'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 50.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: DefaultTabController(
                    length: 2,
                    initialIndex:
                        widget.initialIndex == null ? 0 : widget.initialIndex,
                    child: Column(
                      children: [
                        Container(
                            constraints: BoxConstraints(maxHeight: 150.0),
                            child: TabBar(
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              indicator: BoxDecoration(
                                color: Variables.primaryColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              tabs: [
                                Tab(
                                    text: AppLocalizations.of(context)
                                        .translate('hospitals')),
                                Tab(
                                    text: AppLocalizations.of(context)
                                        .translate('doctors')),
                              ],
                            )),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 0.5),
                            ),
                          ),
                          child: TabBarView(
                            children: [
                              favoriteHospitals(),
                              favoriteDoctors(),
                            ],
                          ),
                        ),
                      ],
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

  Widget favoriteHospitals() {
    return ListView.separated(
        shrinkWrap: true,
        itemCount: _favoriteHospitalList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.black,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_favoriteHospitalList[index].hastaneisim ?? ''),
            subtitle: Text(_favoriteHospitalList[index].sehir ?? ''),
            trailing: Image.asset(
              'assets/images/next.png',
              width: 18,
              height: 18,
            ),
            onTap: () => navigate(_favoriteHospitalList[index]),
          );
        });
  }

  Widget favoriteDoctors() {
    return ListView.separated(
        shrinkWrap: true,
        itemCount: _favoriteDoctorList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.black,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_favoriteDoctorList[index].doktorisim ?? ''),
            //subtitle: Text(_favoriteDoctorList[index].title??''),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_favoriteDoctorList[index].title ?? ''),
                Text(_favoriteDoctorList[index].doktorkurum ?? ''),
                Text(_favoriteDoctorList[index].doktorbolum ?? ''),
              ],
            ),
            trailing: Image.asset(
              'assets/images/next.png',
              width: 18,
              height: 18,
            ),
            onTap: () => navigate(_favoriteDoctorList[index]),
          );
        });
  }
}
