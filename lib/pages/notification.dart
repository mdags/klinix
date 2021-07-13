import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:klinix/models/notification_model.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var _list = <NotificationModel>[];
  bool _isLoading = false;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  void fetchList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var res = await http.get(
          Variables.url +
              '/getNotification?memId=' +
              Variables.memberId.toString(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        var decodeList = json.decode(res.body) as List<dynamic>;
        _list = decodeList.map((i) => NotificationModel.fromJson(i)).toList();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  @override
  Widget build(BuildContext context) {
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_list[index].message.length > 100
                            ? _list[index].message.substring(0, 100)
                            : _list[index].message),
                        subtitle: Text(DateFormat("dd.MM.yyyy HH:mm")
                            .format(DateTime.parse(_list[index].cDate))),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(""),
                                    content: Text(_list[index].message),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate('big_ok')))
                                    ],
                                  ));
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: _list.length),
          ),
          bottomNavigationBar: MyBottomNavigationBar(),
        ),
      ]),
    );
  }
}
