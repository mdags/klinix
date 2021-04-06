import 'package:flutter/material.dart';
import 'package:klinix/pages/change_password.dart';
import 'package:klinix/pages/myaccount.dart';
import 'package:klinix/pages/person.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Variables.greyColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 140.0),
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back_red.png', height: 24.0, width: 24.0,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/sidemenu_background.png'),
                fit: BoxFit.cover)
        ),
        child: bodyWidget(),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }

  Widget bodyWidget() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 40.0,
              width: double.infinity,
              color: Variables.greyColor,
            ),
            Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: Material(
                    color: Colors.white,
                    elevation: 8.0,
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(50),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/appointment_button.png',
                        width: 40, height: 40,),
                      iconSize: 56,
                      splashColor: Variables.primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(AppLocalizations.of(context).translate(
                      'user_info'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),

                buttonWidget(Icon(Icons.settings),
                    AppLocalizations.of(context).translate(
                        'my_profile'), () {
                      Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (context) => MyAccountPage()
                          ));
                    }),
                buttonWidget(Icon(Icons.supervised_user_circle),
                    AppLocalizations.of(context).translate(
                        'big_persons'), () {
                      Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (context) => PersonPage()
                          ));
                    }),
                buttonWidget(Icon(Icons.lock_outline),
                    AppLocalizations.of(context).translate(
                        'change_password'), () {
                      Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (context) => ChangePasswordPage()
                          ));
                    }),
                buttonWidget(Icon(Icons.exit_to_app),
                    AppLocalizations.of(context).translate(
                        'big_logout'), () async {
                      Variables.memberId = null;
                      Variables.tckn = null;
                      Variables.gsm = null;
                      Variables.adsoyad = null;
                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      await preferences.clear();
                      await Navigator.pushReplacementNamed(context, '/home');
                    }),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonWidget(Widget icon, String label, VoidCallback voidCallBack) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Container(
        width: double.infinity,
        height: 50.0,
        child: RawMaterialButton(
          fillColor: Colors.black12,
          splashColor: Variables.primaryColor,
          textStyle: TextStyle(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: icon,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(label,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Image.asset(
                  'assets/images/next.png', color: Colors.white,
                  width: 20.0,
                  height: 20.0,),
              ),
            ],
          ),
          onPressed: voidCallBack,
        ),
      ),
    );
  }
}
