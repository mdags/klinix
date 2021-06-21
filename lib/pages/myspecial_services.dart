import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:klinix/models/requestModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class MySpecialServicesPage extends StatefulWidget {
  @override
  _MySpecialServicesPageState createState() => _MySpecialServicesPageState();
}

class _MySpecialServicesPageState extends State<MySpecialServicesPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  var waitingList = <RequestModel>[];
  var oldList = <RequestModel>[];

  Future<void> getList() async {
    await pr.show();

    var res = await http.get(
        Variables.url +
            '/getWaitingRequest?memberId=' +
            Variables.memberId.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      waitingList = decodeList.map((i) => RequestModel.fromJson(i)).toList();

      res = await http.get(
          Variables.url +
              '/getOldRequest?memberId=' +
              Variables.memberId.toString(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        oldList = decodeList.map((i) => RequestModel.fromJson(i)).toList();
      }

      setState(() {});
    }

    await pr.hide();
  }

  Future<void> cancelRequest(int id) async {
    await pr.show();

    RequestModel request = new RequestModel(rEQUESTID: id, lastStatus: 'İptal');
    var body = json.encode(request.toMap());
    var res = await http.post(Variables.url + '/addRequest',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        },
        body: body);
    if (res.statusCode == 200) {
      await getList();
    }

    await pr.hide();
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
                                    icon: Image.asset(
                                        'assets/images/special_service.png'),
                                    iconSize: 56,
                                    splashColor: Variables.primaryColor,
                                    onPressed: null,
                                  ),
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
                        AppLocalizations.of(context)
                            .translate('big_special_service'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                                            .translate('waiting_appointments')),
                                    Tab(
                                        text: AppLocalizations.of(context)
                                            .translate('past_appointments')),
                                  ],
                                )),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.grey, width: 0.5),
                                ),
                              ),
                              child: TabBarView(
                                children: [
                                  bekleyenWidget(),
                                  iptalWidget(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bekleyenWidget() {
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 50.0),
        shrinkWrap: true,
        itemCount: waitingList.length,
        itemBuilder: (BuildContext context, int index) {
          return buildList(context, waitingList[index], 0);
        });
  }

  Widget iptalWidget() {
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 50.0),
        shrinkWrap: true,
        itemCount: oldList.length,
        itemBuilder: (BuildContext context, int index) {
          return buildList(context, oldList[index], 1);
        });
  }

  Widget buildList(BuildContext context, RequestModel request, int status) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      width: double.infinity,
      height: status == 0 ? 220 : 120,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  height: 70.0,
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Variables.primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateTime.parse(request.requestDate).day.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          request.ay ?? '',
                          maxLines: 1,
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Variables.primaryColor,
                        ),
                        Text(
                          ' ' +
                              DateFormat('HH:mm')
                                  .format(DateTime.parse(request.requestDate)),
                          style: TextStyle(
                              color: Variables.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          request.lastStatus ?? '',
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      request.title ?? '',
                      overflow: TextOverflow.clip,
                      softWrap: true,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      request.city ?? '',
                      overflow: TextOverflow.clip,
                      softWrap: true,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          status == 0
              ? Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Container(
                    width: double.infinity,
                    height: 50.0,
                    child: RawMaterialButton(
                      fillColor: request.lastStatus == "Beklemede"
                          ? Variables.primaryColor
                          : Variables.greyColor,
                      splashColor: Colors.white,
                      textStyle: TextStyle(color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('big_cancel_service'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Image.asset(
                              'assets/images/next.png',
                              color: Colors.white,
                              width: 20.0,
                              height: 20.0,
                            ),
                          ),
                        ],
                      ),
                      onPressed: request.lastStatus == "Beklemede"
                          ? () => cancelRequest(request.rEQUESTID)
                          : null,
                    ),
                  ),
                )
              : Center(),
          Divider(
            color: Colors.black,
            height: 5.0,
          ),
        ],
      ),
    );
  }
}
