import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:klinix/models/pharmaciesModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyPage extends StatefulWidget {
  @override
  _PharmacyPageState createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<PharmaciesModel> pharmacyList = new List<PharmaciesModel>();
  List<PharmaciesModel> filteredPharmacyList = new List<PharmaciesModel>();
  List<String> _ilList = new List<String>();
  List<String> _ilceList = new List<String>();

  String _filteril;
  String _filterilce;
  Color _filterButtonColor = Colors.white;
  Color _filterIconColor = Colors.black;

  final _search = new TextEditingController();
  Color _searchButtonColor = Colors.white;
  Color _searchIconColor = Colors.black;

  filterList() {
    setState(() {
      if (_filteril == null && _filterilce == null) {
        _filterButtonColor = Colors.white;
        _filterIconColor = Colors.black;
        filteredPharmacyList = pharmacyList.toList();
      }
      else {
        filteredPharmacyList = pharmacyList.toList();
        _filterButtonColor = Variables.primaryColor;
        _filterIconColor = Colors.white;

        if (_filteril != null) filteredPharmacyList =
            filteredPharmacyList.where((element) =>
            element.city == _filteril).toList();
        if (_filterilce != null) filteredPharmacyList =
            filteredPharmacyList.where((element) =>
            element.town == _filterilce).toList();
      }
    });
  }

  searchList(String value) {
    if (value.isEmpty) {
      setState(() {
        _searchButtonColor = Colors.white;
        _searchIconColor = Colors.black;
      });
      filterList();
      return;
    }
    setState(() {
      _searchButtonColor = Variables.primaryColor;
      _searchIconColor = Colors.white;
      filteredPharmacyList = filteredPharmacyList
          .where((element) =>
          element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getPharmacies',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      pharmacyList = decodeList.map((i) =>
          PharmaciesModel.fromJson(i)).toList();
      filteredPharmacyList = List.from(pharmacyList);

      pharmacyList.forEach((pharmacy) {
        if (pharmacy.town != null) {
          if (_ilceList.indexWhere((element) =>
          element == pharmacy.town) ==
              -1) {
            _ilceList.add(pharmacy.town);
          }
        }
        if (pharmacy.city != null) {
          if (_ilList.indexWhere((element) => element == pharmacy.city) ==
              -1) {
            _ilList.add(pharmacy.city);
          }
        }
      });

      setState(() {
        _ilList.sort();
        _ilceList.sort();
      });
    }

    await pr.hide();
  }

  Future<void> openMap(konum) async {
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
                              .spaceBetween,
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
                                  color: _filterIconColor,),
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
                                  'assets/images/pharmacy.png',
                                  width: 40, height: 40,),
                                iconSize: 56,
                                splashColor: Variables.primaryColor,
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
                                  color: _searchIconColor,),
                                iconSize: 24,
                                splashColor: Variables.primaryColor,
                                onPressed: () {
                                  _searchBottomSheetMenu();
                                },
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
                        'big_pharmacy_on_duty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Center(
                    child: Text(DateFormat('dd.MM.yyyy').format(DateTime.now())),
                  ),
                  SizedBox(
                    height: 5.0,
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
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(filteredPharmacyList[index].name ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filteredPharmacyList[index].address ?? ''),
                Row(
                  children: [
                    Text(filteredPharmacyList[index].town ?? ''),
                    Text(' / '),
                    Text(filteredPharmacyList[index].city ?? ''),
                  ],
                ),
                filteredPharmacyList[index].tLF != null ?
                RichText(
                  text: TextSpan(
                    text: filteredPharmacyList[index].tLF ?? '',
                    style: new TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launch("tel:" + filteredPharmacyList[index].tLF);
                      },
                  ),
                )
                    : Center(),
              ],
            ),
            trailing: IconButton(
              splashColor: Variables.primaryColor,
              icon: Image.asset(
                'assets/images/pin.png', width: 32, height: 32,),
              onPressed: filteredPharmacyList[index].gPS != null ? () =>
                  openMap(filteredPharmacyList[index].gPS) : null,
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: filteredPharmacyList.length
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
                          topRight: const Radius.circular(10.0)
                      )
                  ),
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
          Text(AppLocalizations.of(context).translate('big_filter'),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filteril,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('city'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true
            ),
            icon: Row(
              children: [
                Image.asset(
                  'assets/images/dropdown.png', width: 18.0, height: 18.0,),
                SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  child: Icon(Icons.cancel, color: Colors.white),
                  onTap: () {
                    setState(() {
                      _filteril = null;

                      _ilceList=[];
                      pharmacyList.forEach((pharmacy) {
                        if (pharmacy.town != null) {
                          if (_ilceList.indexWhere((element) =>
                          element == pharmacy.town) ==
                              -1) {
                            _ilceList.add(pharmacy.town);
                          }
                        }
                      });

                      _ilceList.sort();
                    });
                  },
                ),
              ],
            ),
            items: _ilList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filteril = value;

                if (_filteril != null) {
                  _ilceList=[];
                  List<PharmaciesModel> list = pharmacyList.where((element) => element.city==value).toList();
                  list.forEach((pharmacy) {
                    if (pharmacy.town != null) {
                      if (_ilceList.indexWhere((element) =>
                      element == pharmacy.town) ==
                          -1) {
                        _ilceList.add(pharmacy.town);
                      }
                    }
                  });
                }
                else{
                  pharmacyList.forEach((pharmacy) {
                    if (pharmacy.town != null) {
                      if (_ilceList.indexWhere((element) =>
                      element == pharmacy.town) ==
                          -1) {
                        _ilceList.add(pharmacy.town);
                      }
                    }
                  });
                }

                _ilceList.sort();

              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filterilce,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'town'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true
            ),
            icon: Row(
              children: [
                Image.asset(
                  'assets/images/dropdown.png', width: 18.0, height: 18.0,),
                SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  child: Icon(Icons.cancel, color: Colors.white),
                  onTap: () {
                    setState(() {
                      _filterilce = null;
                    });
                  },
                ),
              ],
            ),
            items: _ilceList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterilce = value;
              });
            },
          ),

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
                          child: Text(AppLocalizations.of(context).translate(
                              'big_clear'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _filterilce = null;
                        _filteril = null;
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
                          child: Text(AppLocalizations.of(context).translate(
                              'big_complete'),
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
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 5.5 +
                      MediaQuery
                          .of(context)
                          .viewInsets
                          .bottom,
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: new BoxDecoration(
                        color: Variables.primaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(10.0),
                            topRight: const Radius.circular(10.0))),
                    child: Column(
                      children: [
                        Container(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                leading: Icon(Icons.search,
                                  color: Variables.primaryColor,
                                ),
                                title: TextField(
                                  controller: _search,
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).translate('search'),
                                      border: InputBorder.none
                                  ),
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
        }
    );
  }
}
