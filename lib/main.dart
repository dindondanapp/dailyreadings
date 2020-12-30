import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common/dailyreadings_preferences.dart';
import 'common/extensions.dart';
import 'common/palette.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DailyReadingsPreferences(
      defaultFontSize: 14.0,
      defaultTheme: ThemeMode.system,
      child: Builder(
        builder: (context) => _buildApp(context),
      ),
    );
  }

  Widget _buildApp(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      primarySwatch: Palette.dinDonDanBlue.toMaterialColor(),
    );

    final ThemeData darkTheme = ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: Palette.dinDonDanBlue,
      accentColor: Palette.dinDonDanBlue,
    );

    return MaterialApp(
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: DailyReadingsPreferences.of(context).theme,
      title: 'Letture del giorno',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
