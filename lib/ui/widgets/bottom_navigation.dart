import 'package:flutter/material.dart';
import 'package:klinix/pages/appointments.dart';
import 'package:klinix/pages/favorites.dart';
import 'package:klinix/pages/home.dart';
import 'package:klinix/pages/hospital_near.dart';
import 'package:klinix/pages/login.dart';
import 'package:klinix/pages/myappointments.dart';
import 'package:klinix/pages/profile.dart';
import 'package:klinix/pages/search.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:spear_menu/spear_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBottomNavigationBar extends StatelessWidget {
  SpearMenu menu;
  GlobalKey btnKey = GlobalKey();
  GlobalKey btnKey1 = GlobalKey();
  List<CustomData> menuList = new List<CustomData>();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFFf2f2f2),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Variables.primaryColor,
      key: btnKey1,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/tab_home.png', height: 20.0, width: 20.0,),
          title: Text("",),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/tab_search.png', height: 20, width: 20.0,),
          title: Text("",),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/tab_heart.png', height: 32, width: 32.0,),
          title: Text("",),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/tab_phone.png', height: 20, width: 20.0,),
          title: Text("",),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/tab_profile.png', height: 20, width: 20.0,),
          title: Text("",),
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (index == 1) {
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context) => SearchPage()
              ));
        }
        if (index == 2) {
          menuData(btnKey1, context);
        }
        if (index == 3) {
          launch("tel:08502555112");
        }
        if (index == 4) {
          if (Variables.memberId != null) {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) => ProfilePage()
                ));
          }
          else {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(
                          destination: 'profile',
                        )
                ));
          }
        }
      },
    );
  }

  void menuData(GlobalKey btnKey, BuildContext context) {
    if (menuList.isEmpty) {
      menuList.clear();
      menuList.add(
          CustomData(Icon(Icons.settings, size: 12.0,),
              '  ' + AppLocalizations.of(context).translate(
                  'quick_menu'),
              TextStyle(color: Colors.black, fontSize: 12.0), false));
      menuList.add(CustomData(Image.asset(
        'assets/images/tab_heart.png', color: Variables.primaryColor,
        width: 12.0,
        height: 12.0,),
          '  ' + AppLocalizations.of(context).translate(
              'make_appointment'),
          TextStyle(color: Variables.primaryColor, fontSize: 12.0), false));
      menuList.add(CustomData(Image.asset(
        'assets/images/tab_heart.png', color: Variables.primaryColor,
        width: 12.0,
        height: 12.0,),
          '  ' + AppLocalizations.of(context).translate(
              'favorite_doctors'),
          TextStyle(color: Variables.primaryColor, fontSize: 12.0), false));
      menuList.add(CustomData(Image.asset(
        'assets/images/tab_heart.png', color: Variables.primaryColor,
        width: 12.0,
        height: 12.0,),
          '  ' + AppLocalizations.of(context).translate(
              'favorite_hospitals'),
          TextStyle(color: Variables.primaryColor, fontSize: 12.0), false));
      menuList.add(CustomData(Image.asset(
        'assets/images/tab_heart.png', color: Variables.primaryColor,
        width: 12.0,
        height: 12.0,),
          '  ' + AppLocalizations.of(context).translate(
              'my_appointments'),
          TextStyle(color: Variables.primaryColor, fontSize: 12.0), false));
      menuList.add(CustomData(Image.asset(
        'assets/images/tab_heart.png', color: Variables.primaryColor,
        width: 12.0,
        height: 12.0,),
          '  ' + AppLocalizations.of(context).translate(
              'nearest_hospital'),
          TextStyle(color: Variables.primaryColor, fontSize: 12.0), false));
      menuList.add(CustomData(
          Icon(Icons.settings, size: 12.0, color: Colors.transparent,),
          '         ',
          TextStyle(color: Colors.black, fontSize: 12.0), false));
    }

    List<MenuItemProvider> setData = new List<MenuItemProvider>();
    setData.clear();
    for (var io in menuList) {
      setData.add(
          MenuItem(
              icon: io.icon,
              title: io.name,
              isActive: false,
              textStyle: io.style
          )
      );
    }

    SpearMenu menu = SpearMenu(
      context: context,
      backgroundColor: Color(0xFFf2f2f2),
      items: setData,
      onClickMenu: (item) {
        menuList.map((element) {
          if (item.menuTitle == element.name) {
            element.isShow = true;
          } else {
            element.isShow = false;
          }
        }).toList();

        if (item.menuTitle == '  ' + AppLocalizations.of(context).translate(
            'make_appointment')) {
          if (Variables.memberId != null) {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        AppointmentsPage()
                ));
          }
          else {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(
                          destination: 'appointment',
                        )
                ));
          }
        }
        else
        if (item.menuTitle == '  ' + AppLocalizations.of(context).translate(
            'favorite_doctors')) {
          if (Variables.memberId != null) {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        FavoritesPage(
                          initialIndex: 1,
                        )
                ));
          }
          else {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(
                          destination: 'favorite',
                          initialIndex: 1,
                        )
                ));
          }
        }
        else if (item.menuTitle == '  ' + AppLocalizations.of(context).translate(
            'favorite_hospitals')) {
          if (Variables.memberId != null) {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        FavoritesPage(
                          initialIndex: 0,
                        )
                ));
          }
          else {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(
                          destination: 'favorite',
                          initialIndex: 0,
                        )
                ));
          }
        }
        else if (item.menuTitle == '  ' + AppLocalizations.of(context).translate(
            'nearest_hospital')) {
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context) => HospitalNearPage()
              ));
        }
        else
        if (item.menuTitle == '  ' + AppLocalizations.of(context).translate(
            'my_appointments')) {
          if (Variables.memberId != null) {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) => MyAppointmentsPage()
                ));
          }
          else {
            Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(
                          destination: 'profile',
                        )
                ));
          }
        }
      },
    );
    menu.show(widgetKey: btnKey);
  }
}

class CustomData {
  var _icon;
  var _name;
  var _style;
  var _isShow;

  Widget get icon => _icon;

  set icon(Widget value) {
    _icon = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  TextStyle get style => _style;

  set style(TextStyle value) {
    _style = style;
  }

  bool get isShow => _isShow;

  set isShow(bool value) {
    _isShow = value;
  }

  CustomData(this._icon, this._name, this._style, this._isShow);
}
