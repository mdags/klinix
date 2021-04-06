import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/pages/person_detail.dart';
import 'package:klinix/pages/person_new.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class PersonPage extends StatefulWidget {
  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  List<MembersModel> _personList = new List<MembersModel>();

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getSubMembers?id=' + Variables.memberId.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      _personList = decodeList.map((i) =>
          MembersModel.fromJson(i)).toList();

      setState(() {

      });
    }

    await pr.hide();
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
              floatingActionButton: FloatingActionButton(
                backgroundColor: Variables.primaryColor,
                child: Icon(Icons.person_add,),
                onPressed: () {
                  Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (context) => PersonNewPage()
                      )).whenComplete(() => getList());
                },
              ),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Material(
                                color: Colors.white,
                                elevation: 8.0,
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(50),
                                child: IconButton(
                                  icon: Icon(Icons.supervised_user_circle,
                                    color: Variables.primaryColor,),
                                  iconSize: 56,
                                  splashColor: Variables.primaryColor,
                                ),
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
                      AppLocalizations.of(context).translate(
                          'big_saved_persons'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
      itemCount: _personList.length,
      itemBuilder: (context, index) =>
          ListTile(
            title: Text(_personList[index].name ?? ' ',
              style: TextStyle(
                color: Variables.primaryColor,
                fontSize: 16.0,
              ),
            ),
            trailing: Image.asset(
              'assets/images/next.png', width: 18, height: 18,),
            subtitle: Text(_personList[index].tCKN ?? ' '),
            onTap: () {
              Navigator.of(context).push(
                  new MaterialPageRoute(
                      builder: (context) =>
                          PersonDetailPage(
                            member: _personList[index],
                          )
                  )).whenComplete(() => getList());
            },
          ),
    );
  }
}
