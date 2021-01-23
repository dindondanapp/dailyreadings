import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/extensions.dart';
import 'common/palette.dart';
import 'common/preferences.dart';
import 'home/home.dart';

void main() async {
  // Perform preliminary operations and preload assets
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await precachePicture(
      ExactAssetPicture(SvgPicture.svgStringDecoder, 'assets/logo.svg'), null);

  final preloaded = MyAppPreloadedData(
    sharedPreferencesInstance: await SharedPreferences.getInstance(),
  );

  // Run app
  runApp(MyApp(preloaded: preloaded));
}

class MyApp extends StatelessWidget {
  final MyAppPreloadedData preloaded;

  MyApp({this.preloaded, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Preferences(
      defaultFontSize: 14.0,
      defaultTheme: ThemeMode.system,
      defaultFullscreen: false,
      sharedPreferencesInstance: preloaded.sharedPreferencesInstance,
      child: Builder(
        builder: (context) => _buildApp(context),
      ),
    );
  }

  Widget _buildApp(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      primarySwatch: Palette.dinDonDanBlue.toMaterialColor(),
      accentColor: Palette.dinDonDanBlue,
    );

    final ThemeData darkTheme = ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: Palette.dinDonDanBlue,
      accentColor: Palette.dinDonDanBlue,
      buttonColor: Colors.grey[700],
    );

    return MaterialApp(
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: Preferences.of(context).theme,
      title: 'Letture del giorno',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

/// An object that can be used to pass to MyApp data preloaded before running
class MyAppPreloadedData {
  final SharedPreferences sharedPreferencesInstance;

  MyAppPreloadedData({@required this.sharedPreferencesInstance});
}
