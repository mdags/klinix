import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/hospital_detail.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class HospitalPage extends StatefulWidget {
  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _hospitalsList = <HospitalsModel>[];
  var _clinicsList = <HospitalsModel>[];
  var _filteredHospitalsList = <HospitalsModel>[];
  var _filteredClinicsList = <HospitalsModel>[];
  var _cityList = <String>[];

  String _filterCategory;
  String _filterSehir;
  Color _filterButtonColor = Colors.white;
  Color _filterIconColor = Colors.black;

  final _search = new TextEditingController();
  Color _searchButtonColor = Colors.white;
  Color _searchIconColor = Colors.black;

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getHospitals?lang=' + Variables.lang + '&category=H',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _hospitalsList =
          decodeList.map((i) => HospitalsModel.fromJson(i)).toList();
      _filteredHospitalsList = _hospitalsList.toList();

      _hospitalsList.forEach((hospital) {
        if (hospital.sehir != null) {
          if (_cityList.indexWhere((element) => element == hospital.sehir) ==
              -1) {
            _cityList.add(hospital.sehir);
          }
        }
      });
    }

    res = await http.get(
        Variables.url + '/getHospitals?lang=' + Variables.lang + '&category=K',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _clinicsList = decodeList.map((i) => HospitalsModel.fromJson(i)).toList();
      _filteredClinicsList = _clinicsList.toList();

      _clinicsList.forEach((hospital) {
        if (hospital.sehir != null) {
          if (_cityList.indexWhere((element) => element == hospital.sehir) ==
              -1) {
            _cityList.add(hospital.sehir);
          }
        }
      });
    }

    setState(() {});

    await pr.hide();
  }

  filterList() {
    setState(() {
      if (_filterCategory == null && _filterSehir == null) {
        _filterButtonColor = Colors.white;
        _filterIconColor = Colors.black;
        _filteredHospitalsList = _hospitalsList.toList();
        _filteredClinicsList = _clinicsList.toList();
      } else {
        _search.clear();
        _searchButtonColor = Colors.white;
        _searchIconColor = Colors.black;

        _filteredHospitalsList = _hospitalsList.toList();
        _filteredClinicsList = _clinicsList.toList();
        _filterButtonColor = Variables.primaryColor;
        _filterIconColor = Colors.white;

        // if (_filterCategory != null) {
        //   _filteredHospitalsList =
        //       _filteredHospitalsList.where((element) =>
        //       element.category == _filterCategory).toList();
        // }
        if (_filterSehir != null) {
          _filteredHospitalsList = _filteredHospitalsList
              .where((element) => element.sehir == _filterSehir)
              .toList();
          _filteredClinicsList = _filteredClinicsList
              .where((element) => element.sehir == _filterSehir)
              .toList();
        }
      }
    });
  }

  searchList(String value) {
    if (value.isEmpty) {
      setState(() {
        _searchButtonColor = Colors.white;
        _searchIconColor = Colors.black;
        //_filteredHospitalsList = _hospitalsList.toList();
      });
      filterList();
      return;
    }
    setState(() {
      _searchButtonColor = Variables.primaryColor;
      _searchIconColor = Colors.white;
      _filteredHospitalsList = _filteredHospitalsList
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
      _filteredClinicsList = _filteredClinicsList
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
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
          key: _scaffoldKey,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              color: _filterButtonColor,
                              elevation: 8.0,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/filter_button.png',
                                  width: 18,
                                  height: 18,
                                  color: _filterIconColor,
                                ),
                                iconSize: 24,
                                splashColor: Variables.primaryColor,
                                onPressed: () => _filterBottomSheetMenu(),
                              ),
                            ),
                            Material(
                              color: Colors.white,
                              elevation: 8.0,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/hospital.png',
                                  width: 40,
                                  height: 40,
                                ),
                                iconSize: 56,
                                splashColor: Variables.primaryColor,
                                onPressed: null,
                              ),
                            ),
                            Material(
                              color: _searchButtonColor,
                              elevation: 8.0,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/search_button.png',
                                  width: 18,
                                  height: 18,
                                  color: _searchIconColor,
                                ),
                                iconSize: 24,
                                splashColor: Variables.primaryColor,
                                onPressed: () {
                                  _searchBottomSheetMenu();
                                },
                              ),
                            ),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).translate('big_hospitals'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ],
          ),
          //Expanded(child: hospitalsListViewWidget()),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: DefaultTabController(
                length: 2,
                initialIndex: 0,
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
                                    .translate('clinics')),
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
                          hospitalsListViewWidget(),
                          clinicsListViewWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget hospitalsListViewWidget() {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) =>
            customListTile(_filteredHospitalsList[index]),
        separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
        itemCount: _filteredHospitalsList.length);
  }

  Widget clinicsListViewWidget() {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) =>
            customListTile(_filteredClinicsList[index]),
        separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
        itemCount: _filteredClinicsList.length);
  }

  Widget customListTile(HospitalsModel hospital) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => HospitalDetailPage(
                  hospital: hospital,
                )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: new IntrinsicHeight(
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                          Text(hospital.sehir ?? ''),
                          Text(hospital.ilce != null ? ' / ' : ''),
                          Text(hospital.ilce ?? ''),
                        ],
                      ),
                      Text(hospital.category ?? ''),
                    ],
                  ),
                ),
              ),
              hospital.indirim > 0
                  ? Container(
                      width: 80.0,
                      height: 32.0,
                      padding: EdgeInsets.only(top: 15.0),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/discount.png'),
                              fit: BoxFit.cover)),
                      child: Column(
                        children: [
                          Text(
                            hospital.indirim.toStringAsFixed(0) + '%',
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
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 5.0),
                child: new Image.asset(
                  'assets/images/next.png',
                  width: 18,
                  height: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _filterBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10.0),
            topRight: const Radius.circular(10.0),
          ),
        ),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 350.0,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                  color: Variables.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: filterWidget(setState),
            );
          });
        });
  }

  Widget filterWidget(StateSetter setState) {
    return Form(
      child: Column(
        children: [
          SizedBox(
            height: 10.0,
          ),
          Text(
            AppLocalizations.of(context).translate('big_filter'),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filterSehir,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('city'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true),
            icon: Row(
              children: [
                Image.asset(
                  'assets/images/dropdown.png',
                  width: 18.0,
                  height: 18.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  child: Icon(Icons.cancel, color: Colors.white),
                  onTap: () {
                    setState(() {
                      _filterSehir = null;
                    });
                  },
                ),
              ],
            ),
            items: _cityList.map((value) {
              return DropdownMenuItem<String>(child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterSehir = value;
              });
            },
          ),

          // SizedBox(
          //   height: 10.0,
          // ),
          // DropdownButtonFormField<String>(
          //   value: _filterCategory,
          //   style: TextStyle(
          //       color: Colors.black
          //   ),
          //   decoration: InputDecoration(
          //       hintText: AppLocalizations.of(context).translate(
          //           'hospital_category'),
          //       hintStyle: TextStyle(color: Colors.white),
          //       fillColor: Colors.white38,
          //       filled: true
          //   ),
          //   icon: Row(
          //     children: [
          //       Image.asset(
          //         'assets/images/dropdown.png', width: 18.0, height: 18.0,),
          //       SizedBox(
          //         width: 10.0,
          //       ),
          //       InkWell(
          //         child: Icon(Icons.cancel, color: Colors.white),
          //         onTap: () {
          //           setState(() {
          //             _filterCategory = null;
          //           });
          //         },
          //       ),
          //     ],
          //   ),
          //   items: _categoryList.map((value) {
          //     return DropdownMenuItem<String>(
          //         child: Text(value), value: value);
          //   }).toList(),
          //   onChanged: (value) {
          //     setState(() {
          //       _filterCategory = value;
          //     });
          //   },
          // ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20.0),
                  width: double.infinity,
                  child: RawMaterialButton(
                    fillColor: Colors.black12,
                    splashColor: Variables.primaryColor,
                    textStyle: TextStyle(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            AppLocalizations.of(context).translate('big_clear'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _filterCategory = null;
                        _filterSehir = null;
                      });
                      filterList();
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20.0),
                  width: double.infinity,
                  child: RawMaterialButton(
                    fillColor: Colors.black12,
                    splashColor: Variables.primaryColor,
                    textStyle: TextStyle(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('big_complete'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      filterList();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _searchBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10.0),
            topRight: const Radius.circular(10.0),
          ),
        ),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height / 5.5 +
                  MediaQuery.of(context).viewInsets.bottom,
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                decoration: new BoxDecoration(
                    color: Variables.primaryColor,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: Column(
                  children: [
                    Container(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.search,
                              color: Variables.primaryColor,
                            ),
                            title: TextField(
                              controller: _search,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)
                                      .translate('search'),
                                  border: InputBorder.none),
                              onChanged: searchList,
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.cancel),
                                  color: Variables.primaryColor,
                                  onPressed: () {
                                    _search.clear();
                                    searchList('');
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.check),
                                  color: Variables.primaryColor,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
