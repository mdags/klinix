import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klinix/pages/home.dart';
import 'package:klinix/pages/hospital_near.dart';
import 'package:klinix/pages/onboard.dart';
import 'package:klinix/ui/helper/AppLanguage.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

int initScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = await prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);

  AppLanguage appLanguage = new AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage appLanguage;

  MyApp({this.appLanguage});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return MaterialApp(
            locale: model.appLocal,
            supportedLocales: [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
              Locale('de', 'DE'),
              Locale('ar', 'AR')
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            title: 'Klinix',
            theme: ThemeData(
                primarySwatch: MaterialColor(0xFFFF000d, color),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: 'Roboto'
            ),
            debugShowCheckedModeBanner: false,
            home: splashWidget(),
            routes: <String, WidgetBuilder>{
              '/home': (BuildContext context) => new HomePage(),
              '/hospital_near': (BuildContext context) => new HospitalNearPage()
            },
          );
        },
      ),
    );
  }

  Widget splashWidget() {
    return SplashScreen(
        seconds: 5,
        navigateAfterSeconds: initScreen == 0 || initScreen == null
            ? OnboardPage()
            : HomePage(),
        title: Text(''),
        image: Image(image: AssetImage("assets/images/splash_animate.gif")),
        backgroundColor: Colors.transparent,
        imageBackground: AssetImage('assets/images/splash_background.png'),
        styleTextUnderTheLoader: TextStyle(),
        
        photoSize: 200.0,
        loaderColor: Colors.transparent
    );
  }

  final Map<int, Color> color =
  {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };
}
