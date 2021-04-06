import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/departmentsModel.dart';
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/doctor.dart';
import 'package:klinix/pages/doctor_detail.dart';
import 'package:klinix/pages/hospital_detail.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final _search = new TextEditingController();
  List<DoctorsModel> _searchList = new List<DoctorsModel>();
  List<DoctorsModel> _filteredSearchList = new List<DoctorsModel>();

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getSearchList?lang=' + Variables.lang,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _searchList = decodeList.map((i) =>
          DoctorsModel.fromJson(i)).toList();

      setState(() {
        //_filteredSearchList = List.from(_searchList);
      });
    }

    await pr.hide();
  }

  search(String value) {
    if (value.isEmpty) {
      setState(() {
        _filteredSearchList = new List<DoctorsModel>();
      });
      return;
    }
    setState(() {
      _filteredSearchList = _searchList
          .where((element) =>
          element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> selectObject(DoctorsModel searchValue) async {
    if (searchValue.p2 == 'Kurum') {
      var res = await http.get(
          Variables.url + '/getHospitalById?id=' + searchValue.p1,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<HospitalsModel> _list = decodeList.map((i) =>
            HospitalsModel.fromJson(i)).toList();

        if (_list.length > 0) {
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context) =>
                      HospitalDetailPage(
                        hospital: _list[0],
                      )
              ));
        }
      }
    }
    else if (searchValue.p2 == 'Bölüm') {
      var res = await http.get(
          Variables.url + '/getDepartmentByWebId?id=' + searchValue.p1 +
              '&lang=' + Variables.lang,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<DepartmentsModel> _list = decodeList.map((i) =>
            DepartmentsModel.fromJson(i)).toList();

        if (_list.length > 0) {
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context) =>
                      DoctorPage(
                        department: _list[0],
                      )
              ));
        }
      }
    }
    else {
      var res = await http.get(
          Variables.url + '/getDoctorById?id=' + searchValue.p1,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        List<DoctorsModel> _list = decodeList.map((i) =>
            DoctorsModel.fromJson(i)).toList();

        if (_list.length > 0) {
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context) =>
                      DoctorDetailPage(
                        doctor: _list[0],
                      )
              ));
        }
      }
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
                height: 60.0,
                color: Variables.greyColor,
              ),
              Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.75,
                      child: Material(
                        elevation: 0,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.grey,
                        child: TextField(
                          controller: _search,
                          autofocus: true,
                          cursorColor: Variables.primaryColor,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).translate(
                                'hdd_search'),
                            hintStyle: TextStyle(
                                color: Colors.white, fontSize: 14.0),
                            prefixIcon: Icon(
                                Icons.search, color: Colors.white),
                            border: InputBorder.none,
                            //contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 13)
                          ),
                          onChanged: search,
                        ),
                      ),
                    ),
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
      separatorBuilder: (context, index) =>
          Divider(
            color: Colors.black,
          ),
      itemCount: _filteredSearchList.length,
      itemBuilder: (context, index) =>
          ListTile(
            leading: _filteredSearchList[index].p2 == 'Kurum' ? Image.asset(
              'assets/images/hospital_lead.png', width: 32,
              height: 32,
              color: Variables.primaryColor,) :
            _filteredSearchList[index].p2 == 'Bölüm' ? Image.asset(
              'assets/images/department_lead.png', width: 32,
              height: 32,
              color: Variables.primaryColor,) :
            Image.asset(
              'assets/images/doctor_lead.png', width: 32,
              height: 32,
              color: Variables.primaryColor,),
            title: RichText(
              text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                text: _filteredSearchList[index].p2 == 'Kurum'?AppLocalizations.of(context).translate('hospital'):
                _filteredSearchList[index].p2 == 'Bölüm'?AppLocalizations.of(context).translate('department'):
                AppLocalizations.of(context).translate('doctor'),
                children: <TextSpan>[
              TextSpan(text:' > '),
              TextSpan(text:_filteredSearchList[index].name),
              TextSpan(text:_filteredSearchList[index].title),
                ]
              ),
            ),
            // Text(
            //   _filteredSearchList[index].p2 == 'Kurum'?AppLocalizations.of(context).translate('hospital'):
            //   _filteredSearchList[index].p2 == 'Bölüm'?AppLocalizations.of(context).translate('department'):
            //   AppLocalizations.of(context).translate('doctor')
            //   + ' > ' +
            //     _filteredSearchList[index].name +
            //     _filteredSearchList[index].title,
            // ),
            trailing: Image.asset(
              'assets/images/next.png', width: 18, height: 18,),
            onTap: () => selectObject(_filteredSearchList[index]),
          ),
    );
  }
}
