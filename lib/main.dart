// main backup
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'common/language/language_controller.dart';
import 'common/services/utils.dart';
import './screens/home.dart';
import './screens/landing.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import '../support/app_theme.dart' as app_theme;

String fontNotoSansTC_VariableFont_wght = 'NotoSansTC-VariableFont_wght';
String fontNotoSansTC_Regular = 'Fuzzy_Bubbles';
String maShanZheng_Regular = 'MaShanZheng-Regular';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await AppLanguageController().getLanguage();
  await AppLanguageController().getLanguageTypeFromLocal();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '',
        theme: ThemeData(
          // fontFamily: maShanZheng_Regular,

          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          useMaterial3: true,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          canvasColor: const Color.fromARGB(240, 30, 30, 30),
          primaryColor: app_theme.primary,
          colorScheme: ColorScheme.fromSwatch(
            errorColor: app_theme.error,
            brightness: Brightness.dark,
            primarySwatch: createMaterialColor(
              app_theme.primary,
            ),
          ).copyWith(
            background: const Color.fromARGB(255, 19, 19, 19),
          ),
        ),
        home: const HomePage(),
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
        initialRoute: '/home',
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          "/landing": (BuildContext context) => const LandingPage(),
          "/home": (BuildContext context) => const HomePage(),
        });
  }
}
