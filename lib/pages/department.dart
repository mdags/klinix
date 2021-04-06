import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/departmentsModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/pages/doctor.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/convertion.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class DepartmentPage extends StatefulWidget {
  final HospitalsModel hospital;

  const DepartmentPage({Key key, this.hospital}) : super(key: key);

  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  List<DepartmentsModel> _departmentsList = new List<DepartmentsModel>();
  List<DepartmentsModel> _filteredDepartmentsList = new List<
      DepartmentsModel>();

  final _search = new TextEditingController();
  Color _searchButtonColor = Colors.white;
  Color _searchIconColor = Colors.black;

  Future<void> getList() async {
    await pr.show();

    if (widget.hospital == null) {
      var res = await http.get(
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
    else {
      var res = await http.get(
          Variables.url + '/getDepartmentsByHospital?id=' +
              widget.hospital.hOSID.toString() +
              '&lang=' + Variables.lang,
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
      _filteredDepartmentsList = List.from(_departmentsList);
    });

    await pr.hide();
  }

  searchList(String value) {
    if (value.isEmpty) {
      setState(() {
        _searchButtonColor = Colors.white;
        _searchIconColor = Colors.black;
        _filteredDepartmentsList = _departmentsList.toList();
      });
      return;
    }
    setState(() {
      _search.clear();
      _searchButtonColor = Colors.white;
      _searchIconColor = Colors.black;

      _searchButtonColor = Variables.primaryColor;
      _searchIconColor = Colors.white;
      _filteredDepartmentsList = _filteredDepartmentsList
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
              backgroundColor: Colors.white,
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
    return Column(
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
                              color: Colors.white,
                              elevation: 8.0,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 48.0,
                              )
                            // IconButton(
                            //   icon: Image.asset(
                            //     'assets/images/filter_button.png',
                            //     width: 18, height: 18,),
                            //   iconSize: 24,
                            //   splashColor: Variables.primaryColor,
                            //   onPressed: () {
                            //
                            //   },
                            // ),
                          ),
                          Material(
                            color: Colors.white,
                            elevation: 8.0,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(50),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/images/department.png',
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
                    AppLocalizations.of(context).translate('big_departments'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(
                    widget.hospital != null ? widget.hospital.name : '',
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
          child: Container(
            child: groupedListViewWidget(),
          ),
        ),
      ],
    );
  }

  Widget groupedListViewWidget() {
    return GroupedListView<DepartmentsModel, String>(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      elements: _filteredDepartmentsList,
      order: GroupedListOrder.ASC,
      floatingHeader: true,
      groupBy: (DepartmentsModel department) => department.name[0],
      groupComparator: (String value1, String value2) =>
          Convertion.convert(value1).compareTo(Convertion.convert(value2)),
      itemComparator: (DepartmentsModel department1,
          DepartmentsModel department2) =>
          Convertion.convert(department1.name).compareTo(
              Convertion.convert(department2.name)),
      groupSeparatorBuilder: (String departmentGroup) =>
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            height: 50.0,
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                      color: Colors.black12
                  )),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    departmentGroup,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      itemBuilder: (_, DepartmentsModel department) {
        return ListTile(
          contentPadding: EdgeInsets.only(
              left: 60.0, right: 40.0, top: 0, bottom: 0),
          title: Text(department.name),
          trailing: Icon(Icons.navigate_next),
          onTap: () {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        DoctorPage(
                          hospitalId: widget.hospital != null ? widget.hospital
                              .hOSID : null,
                          department: department,
                        )
                ));
          },
        );
      },
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
