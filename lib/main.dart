import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common/extensions.dart';
import 'common/palette.dart';
import 'common/preferences.dart';
import 'home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Preferences(
      defaultFontSize: 14.0,
      defaultTheme: ThemeMode.system,
      defaultFullscreen: false,
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
