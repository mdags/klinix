import 'package:flutter/material.dart';
import 'package:klinix/pages/favorites.dart';
import 'package:klinix/pages/login.dart';
import 'package:klinix/pages/myappointments.dart';
import 'package:klinix/pages/myspecial_services.dart';
import 'package:klinix/pages/profile.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MyDrawer extends StatelessWidget {
  double fontSize = 18;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          image: AssetImage("assets/images/sidemenu_background.png"),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120.0,
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).translate('home'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      fontFamily: 'Rubik'),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).translate('my_appointments'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      fontFamily: 'Rubik'),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                onTap: () {
                  if (Variables.memberId != null) {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => MyAppointmentsPage()));
                  } else {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => LoginPage(
                              destination: 'profile',
                            )));
                  }
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).translate('favorites'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      fontFamily: 'Rubik'),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                onTap: () {
                  if (Variables.memberId != null) {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => FavoritesPage()));
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                            AppLocalizations.of(context).translate('info')),
                        content: Text(AppLocalizations.of(context)
                            .translate('fav_error')),
                        actions: [
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).translate('big_ok'),
                              style: TextStyle(color: Variables.primaryColor),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              // ListTile(
              //   title: Text(AppLocalizations.of(context).translate(
              //       'announcements'), style: TextStyle(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //       fontSize: fontSize,
              //       fontFamily: 'Rubik'),
              //   ),
              //   trailing: Icon(Icons.navigate_next, color: Colors.white,),
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       builder: (_) =>
              //           AlertDialog(
              //             title: Text(
              //                 AppLocalizations.of(context).translate('info')),
              //             content: Text(
              //                 AppLocalizations.of(context).translate(
              //                     'no_announcements')),
              //             actions: [
              //               TextButton(
              //                 child: Text(
              //                   AppLocalizations.of(context).translate(
              //                       'big_ok'),
              //                   style: TextStyle(
              //                       color: Variables.primaryColor),
              //                 ),
              //                 onPressed: () {
              //                   Navigator.of(context).pop();
              //                 },
              //               ),
              //             ],
              //           ),
              //     );
              //   },
              // ),
              // ListTile(
              //   title: Text(AppLocalizations.of(context).translate(
              //       'notifications'), style: TextStyle(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //       fontSize: fontSize,
              //       fontFamily: 'Rubik'),
              //   ),
              //   trailing: Icon(Icons.navigate_next, color: Colors.white,),
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       builder: (_) =>
              //           AlertDialog(
              //             title: Text(
              //                 AppLocalizations.of(context).translate('info')),
              //             content: Text(
              //                 AppLocalizations.of(context).translate(
              //                     'no_notification')),
              //             actions: [
              //               TextButton(
              //                 child: Text(
              //                   AppLocalizations.of(context).translate(
              //                       'big_ok'),
              //                   style: TextStyle(
              //                       color: Variables.primaryColor),
              //                 ),
              //                 onPressed: () {
              //                   Navigator.of(context).pop();
              //                 },
              //               ),
              //             ],
              //           ),
              //     );
              //   },
              // ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).translate('my_special_services'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      fontFamily: 'Rubik'),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                onTap: () {
                  if (Variables.memberId != null) {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => MySpecialServicesPage()));
                  } else {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => LoginPage(
                              destination: 'profile',
                            )));
                  }
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).translate('account'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      fontFamily: 'Rubik'),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                onTap: () {
                  if (Variables.memberId != null) {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => ProfilePage()));
                  } else {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => LoginPage(
                              destination: 'profile',
                            )));
                  }
                },
              ),
              Variables.memberId != null
                  ? ListTile(
                      title: Text(
                        AppLocalizations.of(context).translate('logout'),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            fontFamily: 'Rubik'),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        Variables.memberId = null;
                        Variables.tckn = null;
                        Variables.gsm = null;
                        Variables.adsoyad = null;
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        await preferences.clear();
                        await Navigator.pushReplacementNamed(context, '/home');
                      },
                    )
                  : Center(),
            ],
          ),
        )
      ],
    );
  }
}
