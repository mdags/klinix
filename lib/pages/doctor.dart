import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/departmentsModel.dart';
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/doctor_detail.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class DoctorPage extends StatefulWidget {
  final int hospitalId;
  final DepartmentsModel department;

  const DoctorPage({Key key, this.hospitalId, this.department})
      : super(key: key);

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  List<DoctorsModel> _doctorsList = new List<DoctorsModel>();
  List<DoctorsModel> _filteredDoctorsList = new List<DoctorsModel>();
  List<HospitalsModel> _hospitalsList = new List<HospitalsModel>();
  List<DepartmentsModel> _departmentsList = new List<DepartmentsModel>();
  List<String> _categoryList = new List<String>();
  List<String> _titleList = new List<String>();
  List<String> _sexList = new List<String>();

  String _filterHospital;
  String _hospitalName;
  String _filterDepartment;
  String _filterCategory;
  String _filterTitle;
  String _filterSex;
  Color _filterButtonColor = Colors.white;
  Color _filterIconColor = Colors.black;

  final _search = new TextEditingController();
  Color _searchButtonColor = Colors.white;
  Color _searchIconColor = Colors.black;

  Future<void> getList() async {
    await pr.show();

    String urlService = '/getDoctors?lang=' + Variables.lang;
    if (widget.hospitalId != null && widget.department != null) {
      urlService = '/getDoctorsByHosNDep?hosid=' +
          widget.hospitalId.toString() +
          '&depid=' + widget.department.depWebId.toString() +
          '&lang=' + Variables.lang;
    }
    else {
      if (widget.hospitalId != null) urlService = '/getDoctorsByHospital?id=' +
          widget.hospitalId.toString() +
          '&lang=' + Variables.lang;
      if (widget.department != null)
        urlService = '/getDoctorsByDepartment?id=' +
            widget.department.depWebId.toString() +
            '&lang=' + Variables.lang;
    }
    var res = await http.get(
        Variables.url + urlService,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _doctorsList = decodeList.map((i) =>
          DoctorsModel.fromJson(i)).toList();

      _doctorsList.forEach((doctor) {
        if (doctor.title != '') {
          if (_titleList.indexWhere((element) => element == doctor.title) ==
              -1) {
            _titleList.add(doctor.title);
          }
        }
        if (_sexList.indexWhere((element) => element == doctor.sex) == -1) {
          _sexList.add(doctor.sex);
        }
      });

      res = await http.get(
          Variables.url + '/getHospitals?lang=' + Variables.lang+'&category=*',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        _hospitalsList = decodeList.map((i) =>
            HospitalsModel.fromJson(i)).toList();

        _hospitalsList.forEach((hospital) {
          if (hospital.category != null) {
            if (_categoryList.indexWhere((element) =>
            element == hospital.category) ==
                -1) {
              _categoryList.add(hospital.category);
            }
          }
        });


        res = await http.get(
            Variables.url + '/getDepartments?lang=' + Variables.lang,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            });
        if (res.statusCode == 200) {
          var decodeList = json.decode(res.body) as List<dynamic>;
          _departmentsList = decodeList.map((i) =>
              DepartmentsModel.fromJson(i)).toList();
        }
      }

      setState(() {
        _filteredDoctorsList = List.from(_doctorsList);
        _titleList.sort();
        _sexList.sort();

        if (widget.hospitalId != null) {
          if (_hospitalsList.length > 0) {
            _filterButtonColor = Variables.primaryColor;
            _filterIconColor = Colors.white;
            var _hospital = _hospitalsList.firstWhere((element) =>
            element.hOSID == widget.hospitalId);
            _hospitalName = _hospital.name;
            _filterCategory = _hospital.category;
            _filterHospital = widget.hospitalId.toString();
          }
        }
        if (widget.department != null) {
          if (_departmentsList.length > 0) {
            _filterButtonColor = Variables.primaryColor;
            _filterIconColor = Colors.white;
            _filterDepartment = widget.department.depWebId.toString();
          }
        }
      });
    }

    await pr.hide();
  }

  filterList() {
    setState(() {
      if (_filterHospital == null && _filterDepartment == null &&
          _filterCategory == null && _filterTitle == null &&
          _filterSex == null) {
        _filterButtonColor = Colors.white;
        _filterIconColor = Colors.black;
        _filteredDoctorsList = _doctorsList.toList();
      }
      else {
        _search.clear();
        _searchButtonColor = Colors.white;
        _searchIconColor = Colors.black;

        _filteredDoctorsList = _doctorsList.toList();
        _filterButtonColor = Variables.primaryColor;
        _filterIconColor = Colors.white;
        if (_filterHospital != null) _filteredDoctorsList =
            _filteredDoctorsList.where((element) =>
            element.hOSID.toString() ==
                _filterHospital).toList();
        if (_filterDepartment != null) _filteredDoctorsList =
            _filteredDoctorsList.where((element) =>
            element.depWebId.toString() ==
                _filterDepartment).toList();
        if (_filterCategory != null) _filteredDoctorsList =
            _filteredDoctorsList.where((element) =>
            element.kurumTuru ==
                _filterCategory).toList();
        if (_filterTitle != null) _filteredDoctorsList =
            _filteredDoctorsList.where((element) =>
            element.title == _filterTitle).toList();
        if (_filterSex != null) _filteredDoctorsList =
            _filteredDoctorsList.where((element) => element.sex == _filterSex)
                .toList();
      }
    });
  }

  searchList(String value) {
    if (value.isEmpty) {
      setState(() {
        _searchButtonColor = Colors.white;
        _searchIconColor = Colors.black;
        //_filteredDoctorsList = _doctorsList.toList();
      });
      filterList();
      return;
    }
    setState(() {
      _searchButtonColor = Variables.primaryColor;
      _searchIconColor = Colors.white;
      _filteredDoctorsList = _filteredDoctorsList
          .where((element) =>
          element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
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
    pr = ProgressDialog(context, isDismissible: false,);
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
                                onPressed: () {
                                  if (widget.department == null) {
                                    _modalBottomSheetMenu();
                                  }
                                },
                              ),
                            ),
                            Material(
                              color: Colors.white,
                              elevation: 8.0,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/doctor.png',
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
                                onPressed: () => _searchBottomSheetMenu(),
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
                    child: Text(
                      AppLocalizations.of(context).translate('big_doctors'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Center(
                    child: Text(_hospitalName ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Center(
                    child: Text(
                      widget.department != null ? widget.department.name : '',
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
          Expanded(
              child: listViewWidget()
          ),
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
      itemCount: _filteredDoctorsList.length,
      itemBuilder: (context, index) =>
          ListTile(
            //leading: Image.asset('assets/images/doctor_lead.png', width: 32, height: 32,),
            isThreeLine: true,
            title: Text(_filteredDoctorsList[index].name,
              style: TextStyle(
                color: Variables.primaryColor,
                fontSize: 16.0,
              ),
            ),
            trailing: Image.asset(
              'assets/images/next.png', width: 18, height: 18,),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_filteredDoctorsList[index].title ?? ''),
                Text(_filteredDoctorsList[index].kurumAdi ?? ''),
                Text(_filteredDoctorsList[index].brans ?? ''),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                  new MaterialPageRoute(
                      builder: (context) =>
                          DoctorDetailPage(
                            doctor: _filteredDoctorsList[index],
                          )
                  ));
            },
          ),
    );
  }

  void _modalBottomSheetMenu() {
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
                  height: 450.0,
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
            value: _filterCategory,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'hospital_category'),
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
                    if (widget.department == null) {
                      setState(() {
                        _filterCategory = null;
                      });
                    }
                  },
                ),
              ],
            ),
            items: _categoryList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterCategory = value;
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filterHospital,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('hospitals'),
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
                    if (widget.department == null) {
                      setState(() {
                        _filterHospital = null;
                      });
                    }
                  },
                ),
              ],
            ),
            items: _hospitalsList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value.name), value: value.hOSID.toString());
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterHospital = value;
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filterDepartment,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('departments'),
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
                    if (widget.department == null) {
                      setState(() {
                        _filterDepartment = null;
                      });
                    }
                  },
                ),
              ],
            ),
            items: _departmentsList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value.name), value: value.depWebId.toString());
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterDepartment = value;
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filterTitle,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('title'),
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
                    if (widget.department == null) {
                      setState(() {
                        _filterTitle = null;
                      });
                    }
                  },
                ),
              ],
            ),
            items: _titleList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterTitle = value;
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          DropdownButtonFormField<String>(
            value: _filterSex,
            style: TextStyle(
                color: Colors.black
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('sex'),
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
                    if (widget.department == null) {
                      setState(() {
                        _filterSex = null;
                      });
                    }
                  },
                ),
              ],
            ),
            items: _sexList.map((value) {
              return DropdownMenuItem<String>(
                  child: Text(value), value: value);
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filterSex = value;
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
                      if (widget.department == null) {
                        Navigator.of(context).pop();
                        setState(() {
                          _filterHospital = null;
                          _filterDepartment = null;
                          _filterCategory = null;
                          _filterTitle = null;
                          _filterSex = null;
                        });
                        filterList();
                      }
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
                      if (widget.department == null) {
                        filterList();
                      }
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
                                      hintText: AppLocalizations.of(context)
                                          .translate('search'),
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
